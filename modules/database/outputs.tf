output "db_endpoint"    { value = aws_db_instance.main.endpoint }
output "db_port"        { value = aws_db_instance.main.port }
output "db_name"        { value = aws_db_instance.main.db_name }
output "db_sg_id"       { value = aws_security_group.db.id }
output "db_instance_id" { value = aws_db_instance.main.id }
