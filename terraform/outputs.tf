output "connect_instance_id" {
  description = "ID of the Amazon Connect instance"
  value       = aws_connect_instance.main.id
}

output "connect_instance_arn" {
  description = "ARN of the Amazon Connect instance"
  value       = aws_connect_instance.main.arn
}

output "connect_instance_service_role" {
  description = "Service role ARN of the Amazon Connect instance"
  value       = aws_connect_instance.main.service_role
}

output "connect_instance_status" {
  description = "Status of the Amazon Connect instance"
  value       = aws_connect_instance.main.status
}

output "connect_console_url" {
  description = "URL to access the Amazon Connect console"
  value       = "https://${var.instance_alias}.my.connect.aws/"
}