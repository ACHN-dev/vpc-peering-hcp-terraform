variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-southeast-1"
}

variable "backend_vpc_cidr" {
  description = "CIDR block for hc-backend-vpc"
  type        = string
  default     = "192.168.0.0/16"
}
