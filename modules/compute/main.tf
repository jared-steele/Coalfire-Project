# AMI: Amazon Linux 2023 (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# --- Management EC2 (public) ---
resource "aws_instance" "mgmt" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_mgmt_id
  vpc_security_group_ids      = [var.sg_mgmt_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  metadata_options { http_tokens = "required" } # IMDSv2
  tags = merge(var.tags, { Name = "cf-mgmt" })
}

# --- User data for web servers (Apache) ---
locals {
  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf install -y httpd
    systemctl enable --now httpd
    cat >/var/www/html/index.html <<'HTML'
    <h1>Coalfire Challenge</h1>
    <p>Host: $(hostname -f)</p>
    HTML
  EOF
}

# --- Launch Template for ASG instances ---
resource "aws_launch_template" "app" {
  name_prefix            = "cf-app-"
  image_id               = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.sg_app_id]
  user_data              = base64encode(local.user_data)
  metadata_options { http_tokens = "required" }
  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Role = "web" })
  }
}

# --- Auto Scaling Group in application subnet ---
resource "aws_autoscaling_group" "app" {
  name                = "cf-asg"
  min_size            = var.asg_min
  max_size            = var.asg_max
  desired_capacity    = var.asg_min
  vpc_zone_identifier = [var.subnet_app_id]  # private subnet

  health_check_type         = "EC2"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "cf-asg-web"
    propagate_at_launch = true
  }
}

# --- Internal ALB across private subnets (app + backend) ---
resource "aws_lb" "internal" {
  name               = "cf-internal-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [var.subnet_app_id, var.subnet_be_id]
  security_groups    = [var.sg_alb_id]
  idle_timeout       = 60
  tags               = merge(var.tags, { Name = "cf-internal-alb" })
}

resource "aws_lb_target_group" "web" {
  name     = "cf-tg-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
  }
  tags = var.tags
}

# Associate ASG with the target group
resource "aws_autoscaling_attachment" "asg_to_tg" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn    = aws_lb_target_group.web.arn
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type               = "forward"
    target_group_arn   = aws_lb_target_group.web.arn
  }
}
