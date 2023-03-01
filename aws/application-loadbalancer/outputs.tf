output "vpc_id" {
  description = "ID of VPC"
  value       = data.aws_vpc.selected.id
}

output "subnet_ids" {
  description = "ID of Subnets"
  value       = data.aws_subnets.selected.ids
}

output "default_sg_id" {
  description = "ID of security groups"
  value       = data.aws_security_group.selected.id
}

output "load_balancer_url" {
  description = "URL for load balancer"
  value       = aws_lb.lb-frontend.dns_name
}
