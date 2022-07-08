
provider "aws" {
  region = "us-east-1"
}

locals {
  name                     = "demo"
  ec2_db_instance_username = "wordpress"
  ec2_db_instance_password = "wordpress99"
}

resource "aws_instance" "db_ec2_instnace" {
  #checkov:skip=CKV_AWS_79: Skip requiring IMDSv2 for demo code 
  #checkov:skip=CKV_AWS_126: Skip detailed monitoring for demo instance
  #checkov:skip=CKV_AWS_135: EBS Optimized is always on for Nitro EC2 instance types  

  instance_type = "t3.xlarge"
  subnet_id     = var.private_subnets_local_zone
  ami           = data.aws_ami.amazon-linux-2.id

  ebs_block_device {
    volume_size = 40
    volume_type = "gp2"
    device_name = "/dev/xvda"
    encrypted = true
  }

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  key_name = var.ssh_key_name

  user_data = <<EOF
    #!/bin/sh
    curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
    bash mariadb_repo_setup --os-type=rhel  --os-version=7 --mariadb-server-version=10.7

    yum makecache
    yum repolist
    yum install -y MariaDB-server MariaDB-client

    systemctl enable --now mariadb
    systemctl start mariadb

  EOF

  tags = {
    "Name" = "Maria Database Instance"
  }

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}


resource "random_password" "ec2_mariadb_password" {
  length  = 25
  special = false
  # override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name_prefix = "SSM-Instance-Profile"
  role        = aws_iam_role.role.name
}


resource "aws_iam_role" "role" {
  name = "test_role"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
