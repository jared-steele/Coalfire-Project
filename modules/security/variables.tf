variable "vpc_id" {
  type = string
}

variable "admin_cidr" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}