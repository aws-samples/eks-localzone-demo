
resource "aws_dms_replication_subnet_group" "subnet_group" {
  subnet_ids                           = concat(var.private_subnets, [var.private_subnets_local_zone])
  replication_subnet_group_description = "localzone-demo"
  replication_subnet_group_id          = "localzone-demo"
}

# Create a new replication instance
resource "aws_dms_replication_instance" "my-dms-instance" {
  allocated_storage            = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  multi_az                     = false
  preferred_maintenance_window = "sun:10:30-sun:14:30"
  publicly_accessible          = true
  replication_instance_class   = "dms.t3.medium"
  replication_instance_id      = "test-dms-replication-instance"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.subnet_group.id


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
  endpoint_id   = "source-mariadb-lz-ec2"
  password      = "wordpress99"
  username      = "wordpress"
  port          = 3306
  server_name   = aws_instance.db_ec2_instnace.private_ip

}

resource "aws_dms_endpoint" "target_endpoint" {
  engine_name   = "mariadb"
  endpoint_type = "target"
  endpoint_id   = "target-mariadb-rds"
  password      = random_password.rds_password.result
  username      = "admin"
  port          = 3306
  server_name   = split(":",aws_db_instance.rds.endpoint)[0]
}

resource "aws_dms_replication_task" "my_replication_task" {
  source_endpoint_arn      = aws_dms_endpoint.source_endpoint.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target_endpoint.endpoint_arn
  replication_instance_arn = aws_dms_replication_instance.my-dms-instance.replication_instance_arn
  migration_type           = "full-load-and-cdc"
  # table_mappings           = jsonencode(jsondecode(file("${path.module}/table-mappings.json")))
  table_mappings           = file("${path.module}/table-mappings.json")
  replication_task_id      = "my-replication-task"
}



# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created. See the DMS Documentation for
# additional information: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html#CHAP_Security.APIRole
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}
