output "sg_mgmt_id" {
  value = aws_security_group.mgmt.id
}

output "sg_alb_id" {
  value = aws_security_group.alb.id
}

output "sg_app_id" {
  value = aws_security_group.app.id
}
