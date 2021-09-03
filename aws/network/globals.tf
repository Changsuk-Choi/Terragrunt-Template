variable "aws_region" {
  type    = string
  default = null
}

variable "aws_profile" {
  type    = string
  default = null
}

variable "terraform_state_bucket" {
  type    = string
  default = null
}

variable "terraform_network_path" {
  type    = string
  default = null
}

variable "terraform_iam_path" {
  type    = string
  default = null
}

variable "service" {
  type    = string
  default = null
}

variable "project" {
  type    = string
  default = null
}

variable "stage" {
  type    = string
  default = null
}

variable "env" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
