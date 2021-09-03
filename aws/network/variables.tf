variable "vpc_cidr" {
  description = "VPC cidr block. Example: 10.0.0.0/16"
}

variable "public_subnet_common_cidrs" {
  type = list
}

variable "nat_subnet_api_cidrs" {
  type = list
}

variable "private_subnet_cache_cidrs" {
  type = list
}

variable "private_subnet_db_cidrs" {
  type = list
}

variable "availability_zones" {
  type = list
}
