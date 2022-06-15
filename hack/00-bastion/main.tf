
provider "aws" {
  region = "us-east-1"
}

locals {
  subnet_id    = "subnet-0d05de32e811f03c4"
  ssh_key_name = "lindarr"
}

resource "aws_instance" "workstation_ec2_instnace" {

  instance_type = "c5.xlarge"
  subnet_id     = local.subnet_id
  ami           = data.aws_ami.ubuntu.id

  security_groups = [aws_security_group.allow_ssh.id]

  ebs_block_device {
    volume_size = 60
    volume_type = "gp2"
    device_name = "/dev/sda1"
  }

  key_name = local.ssh_key_name


  tags = {
    "Name" = "Workstation"
  }

  iam_instance_profile = "SSMManagedInstanceProfileRole"
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-*-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_security_group" "allow_ssh" {
  vpc_id = "vpc-0c544fbcafdbbb035"
    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "Allow SSH"
      from_port = 22
      protocol = "TCP"
      to_port = 22
    } 
}