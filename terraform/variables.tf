variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "amazon-connect-playground"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_alias" {
  description = "Alias for the Amazon Connect instance"
  type        = string
  default     = "connect-playground"
}

variable "identity_management_type" {
  description = "Type of identity management for the instance"
  type        = string
  default     = "CONNECT_MANAGED"
  
  validation {
    condition     = contains(["CONNECT_MANAGED", "SAML"], var.identity_management_type)
    error_message = "Identity management type must be either CONNECT_MANAGED or SAML."
  }
}

variable "inbound_calls_enabled" {
  description = "Whether inbound calls are enabled for the instance"
  type        = bool
  default     = true
}

variable "outbound_calls_enabled" {
  description = "Whether outbound calls are enabled for the instance"
  type        = bool
  default     = true
}