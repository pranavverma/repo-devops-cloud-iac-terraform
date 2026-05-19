output "alb_dns_name"        { value = aws_lb.main.dns_name }
output "alb_arn"             { value = aws_lb.main.arn }
output "ecs_cluster_id"      { value = aws_ecs_cluster.main.id }
output "ecs_service_name"    { value = aws_ecs_service.app.name }
output "ecs_task_definition" { value = aws_ecs_task_definition.app.arn }
output "alb_sg_id"           { value = aws_security_group.alb.id }
output "ecs_sg_id"           { value = aws_security_group.ecs_tasks.id }
