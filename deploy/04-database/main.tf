
provider "aws" {
  region = "us-east-1"
}

locals {
  name = "demo"
  ec2_db_instance_username = "wordpress"
  ec2_db_instance_password = "wordpress99"
}

resource "aws_instance" "db_ec2_instnace" {

  instance_type = "t3.xlarge"
  subnet_id     = var.private_subnets_local_zone
  ami           = data.aws_ami.amazon-linux-2.id

  ebs_block_device {
    volume_size = 40
    volume_type = "gp2"
    device_name = "/dev/xvda"
  }

  vpc_security_group_ids = [ aws_security_group.rds_security_group.id ]

  key_name = var.ssh_key_name

  user_data = <<EOF
    #!/bin/sh
    curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
    bash mariadb_repo_setup --os-type=rhel  --os-version=7 --mariadb-server-version=10.7

    yum makecache
    yum repolist
    yum install -y MariaDB-server MariaDB-client

    systemctl enable --now mariadb

    mysql -sfu root -e "GRANT ALL PRIVILEGES ON wordpress.* to 'wordpress'@'%' IDENTIFIED BY 'wordpress99';"
    mysql -sfu root -e "GRANT SUPER, RELOAD, PROCESS, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO wordpress@'%';"
    mysql -sfu root -e "FLUSH PRIVILEGES;"

    systemctl stop mariadb

    sudo cp /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.backup
    sudo rm /etc/my.cnf.d/server.cnf 

    sudo tee /etc/my.cnf.d/server.cnf<<EOT
    [mysqld]
    log_bin=/var/lib/mysql/bin-log
    log_bin_index=/var/lib/mysql/mysql-bin.index
    expire_logs_days=2
    binlog_format=ROW
    EOT

    systemctl start mariadb

  EOF

  tags = {
    "Name" = "Maria Database Instance"
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


resource "random_password" "ec2_mariadb_password" {
  length  = 25
  special = false
  # override_special = "!#$%&*()-_=+[]{}<>:?"
}

