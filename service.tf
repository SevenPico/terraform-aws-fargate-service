# ------------------------------------------------------------------------------
# Service Container Definition
# ------------------------------------------------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "container_definition" {
  source  = "registry.terraform.io/cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_image = var.container_image
  container_name  = module.this.id
  command         = var.service_command
  entrypoint = var.container_entrypoint

  log_configuration = {
    logDriver : "awslogs"
    options : {
      awslogs-region : data.aws_region.current.name
      awslogs-create-group : "true"
      awslogs-group : var.ecs_cloudwatch_log_group_name
      awslogs-stream-prefix : "s"
    }
  }

  port_mappings   = concat(var.container_port_mappings, [{
    containerPort : var.container_port
    hostPort : var.container_port
    protocol : "tcp"
    }])

  map_secrets = merge(
    {for key in keys(var.secrets): key => "${aws_secretsmanager_secret.container[0].arn}:${key}:AWSCURRENT:"}
  )
}


# ------------------------------------------------------------------------------
# Service Task
# ------------------------------------------------------------------------------
module "service" {
  source  = "registry.terraform.io/cloudposse/ecs-alb-service-task/aws"
  version = "0.64.0"
  context = module.this.context

  container_definition_json = module.container_definition.json_map_encoded_list
  container_port            = var.container_port
  desired_count             = var.desired_count
  ecs_load_balancers = [{
    elb_name         : null
    target_group_arn : module.alb.default_target_group_arn
    container_name   : module.this.id
    container_port   : var.container_port
  }]

  security_group_ids = [module.service_security_group.id]

  task_role_arn      = [one(aws_iam_role.task_role[*].arn)]
  task_exec_role_arn = [one(aws_iam_role.task_exec_role[*].arn)]
  # service_role_arn   = one(aws_iam_role.service_role[*].arn)
  service_role_arn   = module.this.enabled ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${module.service_role_meta.id}" : ""

  vpc_id                             = var.vpc_id
  ecs_cluster_arn                    = var.ecs_cluster_arn
  subnet_ids                         = var.subnet_ids
  task_cpu                           = var.task_cpu
  task_memory                        = var.task_memory

  platform_version                   = "1.4.0"
  propagate_tags                     = "SERVICE"
  assign_public_ip                   = true # FIXME review
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 10
  enable_ecs_managed_tags            = true
  nlb_container_port                 = var.nlb_container_port
}


# ------------------------------------------------------------------------------
# Service Security Group
# ------------------------------------------------------------------------------
module "service_security_group" {
  source  = "registry.terraform.io/cloudposse/security-group/aws"
  version = "0.4.3"
  context = module.this.context

  vpc_id = var.vpc_id
  security_group_name = [module.this.id]
  security_group_description = "Controls access to the service"
  create_before_destroy = true

  rules_map = var.service_security_group_rules_map
  rules = [for rule in [
    {
      description              = "Allow ingress from ALB to service"
      type                     = "ingress"
      protocol                 = "tcp"
      from_port                = var.container_port
      to_port                  = var.container_port
      source_security_group_id = module.alb_security_group.id
    },
    module.ddb_meta.enabled ? {
      description              = "Allow egress from service to DocumentDB"
      type                     = "egress"
      protocol                 = "tcp"
      from_port                = var.ddb_port
      to_port                  = var.ddb_port
      source_security_group_id = module.ddb.security_group_id
    } : null
  ] : rule if rule != null]
}
