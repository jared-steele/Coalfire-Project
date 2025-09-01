variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

# CIDRs
variable "vpc_cidr" {
  description = "VPC /16"
  type        = string
  default     = "10.1.0.0/16"
}

variable "mgmt_cidr" {
  description = "Management /24"
  type        = string
  default     = "10.1.0.0/24"
}

variable "app_cidr" {
  description = "Application /24"
  type        = string
  default     = "10.1.1.0/24"
}

variable "backend_cidr" {
  description = "Backend /24"
  type        = string
  default     = "10.1.2.0/24"
}

# Access + sizing
variable "admin_cidr" {
  description = "Your public IP/CIDR for SSH"
  type        = string
  default = "38.15.41.176/32"
}

variable "key_name" {
  description = "EC2 keypair name (optional)"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 size"
  type        = string
  default     = "t2.micro"
}

variable "asg_min" {
  description = "Minimum size of Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max" {
  description = "Maximum size of Auto Scaling Group"
  type        = number
  default     = 6
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Project = "coalfire-challenge"
  }
}
