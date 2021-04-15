output "opa18_db_instance_name" {
  value = aws_db_instance.db.name
}

output "opa18_db_instance_endpoint" {
  value = aws_db_instance.db.endpoint
}

output "opa18_db_instance_username" {
  value = aws_db_instance.db.username
}
