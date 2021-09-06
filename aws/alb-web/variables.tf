variable "allow_http_cidr_blocks" {
  type        = list
  default     = [ "0.0.0.0/0" ]
  description = "Specify cidr blocks that are allowed to acces the LoadBalancer on 80 port"
}

variable "target_type" {
  type        = string
  default     = "instance"
  description = "Type of target that you must specify when registering targets with this target group."
}

variable "logging_bucket" {
  type        = string
  description = "Bucket which store access logs that capture detailed information about requests sent to your load balancer"
}
