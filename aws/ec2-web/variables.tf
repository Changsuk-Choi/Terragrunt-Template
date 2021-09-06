variable "ami" {
  type        = map
  description = "list Amazon Linux AMIs for each region in AWS"

  default = {
    us-east-1      = "ami-0533f2ba8a1995cf9" # amzn2-ami-hvm-2.0.20210318.0-x86_64-gp2
    us-west-2      = "ami-05b622b5fa0269787" # amzn2-ami-hvm-2.0.20210318.0-x86_64-gp2
    ap-northeast-1 = "ami-0bc8ae3ec8e338cbc" # amzn2-ami-hvm-2.0.20210318.0-x86_64-gp2
    ap-northeast-2 = "ami-081511b9e3af53902" # amzn2-ami-hvm-2.0.20210318.0-x86_64-gp2
  }
}

variable "bespin_cidrs" {
  type    = list
  default = [ "58.151.93.7/32" ]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "volume_size" {
  default = 16
}

variable "instance_number" {
  default = 2
}
