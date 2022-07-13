provider "aws" {
  region = "us-east-1" 
}

resource "aws_efs_file_system" "wordpress" {
  encrypted = true
     #checkov:skip=CKV_AWS_194: For demo code, we don't use customer managed keys to encrypt EFS data
}

locals {

}


resource "aws_efs_access_point" "wordpress_ap" {
  file_system_id = aws_efs_file_system.wordpress.id
  posix_user {
    uid = 1000
    gid = 1000
  }
  root_directory {
    path = "/wordpress"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0777"
    }
  }

  depends_on = [
    aws_efs_file_system.wordpress
  ]
}

resource "aws_efs_mount_target" "default" {
  count          = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  file_system_id = aws_efs_file_system.wordpress.id
  #   ip_address     = var.mount_target_ip_address
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs_mount.id]


  depends_on = [
    aws_efs_file_system.wordpress,
    aws_security_group.efs_mount
  ]
}

resource "aws_security_group" "efs_mount" {
  vpc_id = var.vpc_id
  description = "Security Group for EFS Mount Targets"
  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow NFS incoming connection"
    from_port   = 2049
    protocol    = "tcp"
    to_port     = 2049
  }
}

