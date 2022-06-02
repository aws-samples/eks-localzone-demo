resource "aws_db_instance" "rds" {

  identifier           = "test-mariadb-instance"
  instance_class       = "db.m5.large"
  engine               = "mariadb"
  username             = "admin"
  password             = random_password.rds_password.result
  allocated_storage    = 30
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
}

resource "aws_db_subnet_group" "subnet_group" {
  subnet_ids = var.private_subnets
}

resource "random_password" "rds_password" {
  length  = 25
  special = false
  # override_special = "!#$%&*()-_=+[]{}<>:?"

}
