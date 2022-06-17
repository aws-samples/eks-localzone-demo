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
