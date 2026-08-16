variable "project_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of the Log Analytics Workspace for centralized container logging."
}

variable "subnet_id" {
  type        = string
  description = "ID of the delegated subnet where the Container Apps Environment will be deployed."
}