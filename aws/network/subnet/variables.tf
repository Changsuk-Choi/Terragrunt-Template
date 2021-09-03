variable "vpc_id" {
  description = "VPC id to place to subnet into"
}

variable "cidrs" {
  type        = list
  description = "List of cidrs, for every avalibility zone you want you need one"
}

variable "azones" {
  type        = list
  description = "List of avalibility zones you want"
}

variable "name" {}

variable "type" {}

variable "tags" {
  type    = map
  default = {}
}
