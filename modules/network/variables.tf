variable "vpc_cidr" {
  type = string
}

variable "mgmt_cidr" {
  type = string
}

variable "app_cidr" {
  type = string
}

variable "backend_cidr" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}