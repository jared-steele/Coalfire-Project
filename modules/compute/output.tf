output "mgmt_public_ip" {
  value = aws_instance.mgmt.public_ip
}

output "alb_dns_name" {
  value = aws_lb.internal.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.app.name
}
