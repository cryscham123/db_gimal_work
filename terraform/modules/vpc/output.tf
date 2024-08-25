output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main_vpc.id
}

output "public-1_subnets" {
  description = "ID of public subnets"
  value       = aws_subnet.public-1.id
}

output "public-2_subnets" {
  description = "ID of public subnets"
  value       = aws_subnet.public-2.id
}

output "default_sg_id" {
  description = "ID of default security group"
  value       = aws_security_group.default_sg.id
}

output "rds_sg_id" {
  description = "ID of rds security group"
  value       = aws_security_group.rds_sg.id
}

output "rds_sg_name" {
  description = "ID of RDS security group"
  value       = aws_db_subnet_group.rds_subnet_group.name
}
