# nets
variable "vpc_id" {
  type = string
}

variable "subnet_mgmt_id" {
  type = string
}

variable "subnet_app_id" {
  type = string
}

variable "subnet_be_id" {
  type = string
}

# sgs
variable "sg_mgmt_id" {
  type = string
}

variable "sg_app_id" {
  type = string
}

variable "sg_alb_id" {
  type = string
}

# sizing
variable "instance_type" {
  type = string
}

variable "key_name" {
  type    = string
  default = null
}

variable "asg_min" {
  type = number
}

variable "asg_max" {
  type = number
}

variable "tags" {
  type    = map(string)
  default = {}
}
