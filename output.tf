output "enhanced_monitoring_iam_role_name" {
  description = "The name of the monitoring role"
  value       = aws_iam_role.tlz_iam_role_enhanced_monitoring.*.name
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the monitoring role"
  value       = aws_iam_role.tlz_iam_role_enhanced_monitoring.*.arn
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.tlz_db_instance.*.address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.tlz_db_instance.*.arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = aws_db_instance.tlz_db_instance.*.availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.tlz_db_instance.*.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = aws_db_instance.tlz_db_instance.*.hosted_zone_id
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.tlz_db_instance.*.id
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = aws_db_instance.tlz_db_instance.*.resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.tlz_db_instance.*.status
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.tlz_db_instance.*.name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.tlz_db_instance.*.username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.tlz_db_instance.*.port
}

output "db_security_group_id" {
  description = "The database security group."
  value       = aws_security_group.tlz_security_group_db.*.id
}
