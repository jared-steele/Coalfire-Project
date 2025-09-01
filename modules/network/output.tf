output "vpc_id" { value = aws_vpc.this.id }
output "subnet_ids" {
  value = { mgmt = aws_subnet.mgmt.id, app = aws_subnet.app.id, backend = aws_subnet.backend.id }
}