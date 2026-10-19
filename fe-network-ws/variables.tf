variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-southeast-1"
}

variable "frontend_vpc_cidr" {
  description = "CIDR block for hc-frontend-vpc"
  type        = string
  default     = "10.0.0.0/16"
}
