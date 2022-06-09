variable "subnets" {
  default = [
    "subnet-04bfbdb56eab20f3f",
    "subnet-0282d89055cab1760",
    "subnet-0e3d213bfb21127fa",
  ]
  type = list(string)
}

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_id" {
  type = string
}