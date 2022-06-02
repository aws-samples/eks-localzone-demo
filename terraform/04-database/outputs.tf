output "rds_endpoint" {
  value = resource.aws_db_instance.rds.endpoint
}

output "db_ec2_instance_id" {
  value = resource.aws_instance.db_ec2_instnace.id
}

output "rds_password" {
  sensitive = true
  value     = resource.random_password.rds_password.result
}


output "ec2_mariadb_password" {
  sensitive = true
  value     = resource.random_password.ec2_mariadb_password.result
}
