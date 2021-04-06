resource "aws_ecr_repository" "opa18-hub" {
  name                 = "opa18-hub"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name               = "${var.app_name}-cluster"
  capacity_providers = [aws_ecs_capacity_provider.capacity-provider.name]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = "${var.app_name}-task-definition"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode       = "bridge"
  requires_compatibilities = [
    "EC2",
  ]
  cpu    = var.hub_container_cpu
  memory = var.hub_container_memory

  volume {
    name = "opa_volume"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.opa-18-storage.id
    }
  }

  container_definitions = templatefile(
    "${path.module}/templates/task_definition_opahub.json.tpl",
    {
      app_name          = var.app_name
      app_image         = format("%s%s", data.aws_caller_identity.current_opa.account_id,var.opa18_app_image)
      server_port       = var.server_port
      aws_region        = var.region
      container_version = var.container_version
      opahub_password   = var.opahub_password
      db_host           = aws_db_instance.opa18-hub-db.endpoint
      db_user           = var.db_user
      db_password       = var.db_password
      hub_password      = var.opahub_password
      wl_password       = var.wl_password
      as_hostname       = var.opa18_endpoint
      wl_mem_args       = var.wl_mem_args
    }
  )

  tags = local.tags
}

# resource "aws_ecs_task_definition" "ecs_connector_task_definition" {
#   family             = "${var.connector_app_name}-task-definition"
#   execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
#   network_mode       = "bridge"
#   requires_compatibilities = [
#     "EC2",
#   ]
#   cpu    = var.connector_container_cpu
#   memory = var.connector_container_memory
#
#   container_definitions = templatefile(
#     "${path.module}/templates/task_definition_connector.json.tpl",
#     {
#       connector_app_name    = var.connector_app_name
#       connector_ecr_repo    = var.connector_ecr_repo
#       connector_server_port = var.connector_server_port
#       aws_region            = var.region
#       connector_version     = var.container_version
#
#       spring_profile                                   = var.spring_profile
#       spring_mail_host                                 = var.spring_mail_host
#       spring_mail_port                                 = var.spring_mail_port
#       spring_mail_username                             = var.spring_mail_username
#       spring_mail_password                             = var.spring_mail_password
#       spring_mail_properties_mail_smtp_auth            = var.spring_mail_properties_mail_smtp_auth
#       spring_mail_properties_mail_smtp_starttls_enable = var.spring_mail_properties_mail_smtp_starttls_enable
#       fraud_from_email                                 = var.fraud_from_email
#       fraud_to_email                                   = var.fraud_to_email
#       feedback_from_email                              = var.feedback_from_email
#       feedback_to_email                                = var.feedback_to_email
#     }
#   )
#
#   tags = local.tags
# }

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.app_name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.hub_app_count
  launch_type     = "EC2"

  health_check_grace_period_seconds = 300

  ordered_placement_strategy {
    field = "attribute:ecs.availability-zone"
    type  = "spread"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.id
    container_name   = "${var.app_name}-container"
    container_port   = var.server_port
  }

  depends_on = [
    aws_lb_listener.listener,
    aws_iam_role_policy_attachment.ecs_task_execution_role,
    aws_efs_mount_target.opa-18-mount,
    aws_efs_mount_target.opa-18-mount_B,
    aws_efs_mount_target.opa-18-mount_C,
  ]

  //tags = local.tags
}

resource "aws_ecs_capacity_provider" "capacity-provider" {
  name = "${var.app_name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.cluster-scaling-group.arn
  }

  tags = local.tags
}
