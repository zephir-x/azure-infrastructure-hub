variable "project_prefix" {
  type    = string
  default = "mthub"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "polandcentral"
}

variable "base_cidr" {
  type    = string
  default = "10.40.0.0/22"
}

variable "stripe_secret_key" {
  type      = string
  sensitive = true
}

variable "stripe_webhook_secret" {
  type      = string
  sensitive = true
}

variable "deepseek_api_key" {
  type      = string
  sensitive = true
}