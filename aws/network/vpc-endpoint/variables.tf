variable "aws_region" {}

variable "vpc_id" {
  description = "VPC id to place to subnet into"
}

variable "nat_rt_ids" {
  type        = list
  description = "A list of NAT route table"
}

variable "name" {}

variable "tags" {
  type    = map
  default = {}
}
