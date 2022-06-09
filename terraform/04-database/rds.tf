resource "aws_db_instance" "rds" {

  identifier = "test-mariadb-instance"
  instance_class       = "db.m5.large"
  engine               = "mariadb"
  username             = "admin"
  password             = random_password.rds_password.result
  allocated_storage    = 30
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
}



resource "aws_db_instance" "mysql_rds" {
  instance_class       = "db.m5.large"
  engine               = "mysql"
  username             = "admin"
  password             = random_password.rds_password.result
  allocated_storage    = 30
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
}



resource "aws_db_subnet_group" "subnet_group" {
  subnet_ids = var.private_subnets
}

resource "random_password" "rds_password" {
  length  = 25
  special = false
}


resource "aws_security_group" "rds_security_group" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow RDS incoming connection"
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
  }
}