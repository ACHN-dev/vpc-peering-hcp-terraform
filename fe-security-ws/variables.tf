variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-southeast-1"
}

variable "my_ip" {
  description = "Workstation IP in CIDR notation"
  type        = string
  default     = "0.0.0.0/0"
}
