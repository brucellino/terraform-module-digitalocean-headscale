variable "lb_enabled" {
  type        = bool
  default     = false
  description = "Should we enable a load balancer?"
}

variable "vpc_name" {
  default = "hashi-at-home"
}
