variable "vpc_id" {
  type = string
  description = "The IP of the VPC"
}

variable "private_subnets" {
  type = list(string)
}

variable "private_subnets_local_zone" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "domain_name_in_route53" {
  type = string
}