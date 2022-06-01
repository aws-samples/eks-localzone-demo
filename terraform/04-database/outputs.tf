output "rds_endpoint" {
  value = resource.aws_db_instance.rds.endpoint
}

output "db_ec2_instance_id" {
  value = resource.aws_instance.db-ec2-instnace.id
}

output "db_password" {
  sensitive = true
  value = resource.random_password.password.result
}
