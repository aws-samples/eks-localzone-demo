resource "aws_db_instance" "rds" {

  identifier           = "test-mariadb-instance"
  instance_class       = "db.m5.large"
  engine               = "mariadb"
  username             = "admin"
  password             = random_password.password.result
  allocated_storage    = 30
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
}

resource "aws_db_subnet_group" "subnet_group" {
  subnet_ids = var.private_subnets
}

# resource "aws_dms_replication_instance" "my-repl-instance" {
#   allocated_storage          = 50
#   multi_az                   = false
#   publicly_accessible        = false
#   replication_instance_class = "dms.t3.medium"
#   replication_instance_id    = "my-repl-instance"
# }

# resource "aws_dms_endpoint" "source_endpoint" {
#   endpoint_type = "source"
#   engine_name   = "mariadb"
#   endpoint_id   = "source-mariadb-lz-ec2"
# }

# resource "aws_dms_endpoint" "target_endpoint" {

#   engine_name   = "mariadb"
#   endpoint_type = "target"
#   endpoint_id   = "target-mariadb-rds"

# }

# resource "aws_dms_replication_task" "name" {
#   source_endpoint_arn      = aws_dms_endpoint.source_endpoint.endpoint_arn
#   target_endpoint_arn      = aws_dms_endpoint.target_endpoint.endpoint_arn
#   replication_instance_arn = aws_dms_replication_instance.my-repl-instance.replication_instance_arn
#   migration_type           = "full-load-and-cdc"
#   table_mappings           = "" // TODO 
#   replication_task_id      = "my-replication-task"
# }
