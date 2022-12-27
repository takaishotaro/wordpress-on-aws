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

variable "wp_username" {}

variable "wp_email" {}

variable "wp_password" {}
