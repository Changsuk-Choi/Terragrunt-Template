variable "aws_region" {}

variable "vpc_id" {
  description = "VPC id to place to subnet into"
}

variable "igw_id" {
  description = "Internet Gateway id route to public"
}

variable "ngw_ids" {
  type        = list
  description = "Provisioned NAT Gateway Id for each of your private networks"
}

variable "public_subnet_ids" {
  type        = list
  description = "A list of public subnets inside the VPC"
}

variable "nat_subnet_ids" {
  type        = list
  description = "A list of NAT subnets inside the VPC"
}

variable "cache_subnet_ids" {
  type        = list
  description = "A list of private subnets inside the VPC"
}

variable "db_subnet_ids" {
  type        = list
  description = "A list of private subnets inside the VPC"
}


variable "name" {}

variable "tags" {
  type    = map
  default = {}
}
