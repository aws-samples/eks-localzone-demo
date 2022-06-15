variable "vpc_id" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}

variable "vpc_cidr_block" {
  type = string
}

