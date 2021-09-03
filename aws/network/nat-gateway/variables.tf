variable "azones" {
  type        = list
  description = "List of avalibility zones you want. Example: eu-west-1a and eu-west-1b"
}

variable "subnet_ids" {
  type        = list
  description = "List of public subnet ids"
}

variable "name" {}

variable "tags" {
  type    = map
  default = {}
}
