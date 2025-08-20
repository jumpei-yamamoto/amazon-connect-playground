provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Amazon Connect Instance
resource "aws_connect_instance" "main" {
  identity_management_type = var.identity_management_type
  inbound_calls_enabled    = var.inbound_calls_enabled
  instance_alias          = var.instance_alias
  outbound_calls_enabled  = var.outbound_calls_enabled
}