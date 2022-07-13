variable "private_subnets" {
  type = list(string)

}

variable "private_subnets_local_zone" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_id" {
  type = string
}

# IAM roles
variable "create_iam_roles" {
  description = "Determines whether the required [DMS IAM resources](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html#CHAP_Security.APIRole) will be created"
  type        = bool
  default     = true
}
