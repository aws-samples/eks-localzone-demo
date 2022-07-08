resource "aws_db_instance" "rds" {
  #checkov:skip=CKV_AWS_157: Use single AZ for demo code
  #checkov:skip=CKV_AWS_129: Skip logging for demo code
  #checkov:skip=CKV_AWS_118: Skip EM for demo code 

  identifier             = "${local.name}-test-mariadb-instance"
  instance_class         = "db.m5.large"
  engine                 = "mariadb"
  username               = "admin"
  password               = random_password.rds_password.result
  allocated_storage      = 30
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  skip_final_snapshot    = true
  auto_minor_version_upgrade = true
  storage_encrypted = true
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
  description = "Security Groups for RDS"
  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow RDS incoming connection"
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    description = "Allow Outbound connection"
  }
}
