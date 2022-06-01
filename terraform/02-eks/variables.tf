variable "vpc_id" {
  type = string
}

variable "az_private_subnet_ids" {
  type = list(string)
}

variable "local_zone_private_subnet_id" {
  type = string
}

variable "cluster_name" {
  type = string
}