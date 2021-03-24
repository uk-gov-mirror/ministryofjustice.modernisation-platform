output "opa18_db_instance_name" {
  value = aws_db_instance.opa18-hub-db.name
}

output "opa18_db_instance_endpoint" {
  value = aws_db_instance.opa18-hub-db.endpoint
}

output "opa18_db_instance_username" {
  value = aws_db_instance.opa18-hub-db.username
}
