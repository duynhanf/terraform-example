output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.my_vpc_public_subnet_instance_1.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.my_vpc_public_subnet_instance_1.public_ip
}

