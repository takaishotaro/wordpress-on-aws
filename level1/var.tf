variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "env_code" {
  type = string
}

variable "vpc_cidr" {}

variable "private_cidr" {}

variable "public_cidr" {}

variable "az" {}
