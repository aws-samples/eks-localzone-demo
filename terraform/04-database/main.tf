
provider "aws" {
  region = "us-east-1"
}

locals {
}

resource "aws_instance" "db-ec2-instnace" {

  instance_type = "r5d.2xlarge"
  subnet_id     = var.private_subnets_local_zone
  ami           = data.aws_ami.amazon-linux-2.id

  ebs_block_device {
    volume_size = 30
    volume_type = "gp2"
    device_name = "/dev/xvda"
  }

  key_name = var.ssh_key_name

  user_data = <<EOF
    #!/bin/sh
    yum -y update
    curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
    bash mariadb_repo_setup --os-type=rhel  --os-version=7 --mariadb-server-version=10.7

    yum makecache
    yum repolist

    yum install -y MariaDB-server MariaDB-client
    systemctl enable --now mariadb

  EOF

  tags = {
    "Name" = "Database Instance"
  }

  iam_instance_profile = "SSMManagedInstanceProfileRole"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

resource "random_password" "password" {
  length           = 20
  special = false
  # override_special = "!#$%&*()-_=+[]{}<>:?"

}
