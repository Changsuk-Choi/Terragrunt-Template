variable "timeout" {
  default = "120"
}

variable "memory_size" {
  default     = 128
  description = "The amount of memory available to the function during execution. Choose an amount between 128 MB and 3,008 MB in 64 MB increments."
}

variable "schedule_expression" {
  default = "cron(00 1 * * ? *)"
}
