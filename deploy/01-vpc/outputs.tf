output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(module.vpc.vpc_id, "")
}

output "vpc_id_cidr" {
  value = try(module.vpc.vpc_cidr_block)
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets_local_zone" {
  value = aws_subnet.public-subnet-lz.id
}

output "private_subnets_local_zone" {
  value = aws_subnet.private-subnet-lz.id
}