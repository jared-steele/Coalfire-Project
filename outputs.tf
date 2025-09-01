output "vpc_id" {
  value = module.network.vpc_id
}

output "subnets" {
  value = module.network.subnet_ids
}

output "mgmt_public_ip" {
  value = module.compute.mgmt_public_ip
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "asg_name" {
  value = module.compute.asg_name
}
