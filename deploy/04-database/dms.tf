



resource "aws_dms_replication_subnet_group" "subnet_group" {
  subnet_ids                           = concat(var.private_subnets, [var.private_subnets_local_zone])
  replication_subnet_group_description = "${local.name} localzone"
  replication_subnet_group_id          = "${local.name}-local-zone-subnetgroup"
}

# Create a new replication instance
resource "aws_dms_replication_instance" "my-dms-instance" {
  allocated_storage            = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  multi_az                     = false
  preferred_maintenance_window = "sun:10:30-sun:14:30"
  publicly_accessible          = false
  replication_instance_class   = "dms.t3.medium"
  replication_instance_id      = "${local.name}-dms-replication-instance"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.subnet_group.id
     #checkov:skip=CKV_AWS_212: For demo code, we use the default key
  tags = {
    Name = "my-dms-instance"
  }

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]

}

resource "aws_dms_endpoint" "source_endpoint" {
  endpoint_type = "source"
  engine_name   = "mariadb"
  endpoint_id   = "${local.name}-source-mariadb-lz-ec2"
  password      = local.ec2_db_instance_password
  username      = local.ec2_db_instance_username
  port          = 3306
  server_name   = aws_instance.db_ec2_instnace.private_ip

}

resource "aws_dms_endpoint" "target_endpoint" {
  engine_name   = "mariadb"
  endpoint_type = "target"
  endpoint_id   = "${local.name}-target-mariadb-rds"
  password      = random_password.rds_password.result
  username      = "admin"
  port          = 3306
  server_name   = split(":", aws_db_instance.rds.endpoint)[0]
}

resource "aws_dms_replication_task" "my_replication_task" {
  source_endpoint_arn      = aws_dms_endpoint.source_endpoint.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target_endpoint.endpoint_arn
  replication_instance_arn = aws_dms_replication_instance.my-dms-instance.replication_instance_arn
  migration_type           = "full-load-and-cdc"
  table_mappings           = file("${path.module}/table-mappings.json")
  replication_task_id      = "${local.name}-replication-task"
}



# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created. See the DMS Documentation for
# additional information: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html#CHAP_Security.APIRole
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

data "aws_iam_policy_document" "dms_assume_role" {
  count = var.create_iam_roles ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  count = var.create_iam_roles ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.dms_assume_role[0].json
  name               = "dms-access-for-endpoint"
  # https://github.com/hashicorp/terraform-provider-aws/issues/11025#issuecomment-660059684

  provisioner "local-exec" {
    command = "sleep 10"
  }
}


resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  count = var.create_iam_roles ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.dms_assume_role[0].json
  name               = "dms-cloudwatch-logs-role"
  # https://github.com/hashicorp/terraform-provider-aws/issues/11025#issuecomment-660059684
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "aws_iam_role" "dms-vpc-role" {
  count = var.create_iam_roles ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.dms_assume_role[0].json
  name               = "dms-vpc-role"
  # https://github.com/hashicorp/terraform-provider-aws/issues/11025#issuecomment-660059684
  provisioner "local-exec" {
    command = "sleep 10"
  }

}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  count = var.create_iam_roles ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role[0].name
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  count = var.create_iam_roles ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint[0].name
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  count = var.create_iam_roles ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role[0].name
}
