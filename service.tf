## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./service.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Service Container Definition
# ------------------------------------------------------------------------------
locals {
  container_name = module.context.name == "" ? module.context.id : module.context.name
}

module "container_definition" {
  source  = "registry.terraform.io/cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_image = var.container_image
  container_name  = local.container_name
  command         = var.service_command
  entrypoint      = var.container_entrypoint

  linux_parameters = {
    capabilities = {
      add  = []
      drop = []
    }
    devices            = []
    initProcessEnabled = true
    maxSwap            = null
    sharedMemorySize   = null
    swappiness         = null
    tmpfs              = []
  }

  log_configuration = {
    logDriver : "awslogs"
    options : {
      awslogs-region : data.aws_region.current.name
      awslogs-create-group : "true"
      awslogs-group : var.ecs_cloudwatch_log_group_name
      awslogs-stream-prefix : "s"
    }
  }

  port_mappings = concat(var.container_port_mappings, [{
    containerPort : var.container_port
    hostPort : var.container_port
    protocol : "tcp"
  }])

  map_secrets = merge(
    module.service_configuration_context.enabled ? { for key in keys(var.secrets) : key => "${module.service_configuration.arn}:${key}:AWSCURRENT:" } : {},
    var.additional_secrets
  )
}


# ------------------------------------------------------------------------------
# Service Task
# ------------------------------------------------------------------------------
module "service" {
  source  = "registry.terraform.io/SevenPicoForks/ecs-alb-service-task/aws"
  version = "2.0.0"
  context = module.context.self

  container_definition_json = module.container_definition.json_map_encoded_list
  container_port            = var.container_port
  desired_count             = var.desired_count
  ecs_load_balancers = concat(
    var.ecs_additional_load_balancer_mapping,
    var.enable_alb ? [{
      elb_name : null
      target_group_arn : one(module.alb[*].default_target_group_arn)
      container_name : local.container_name
      container_port : var.container_port
    }] : []
  )

  security_group_ids = [module.service_security_group.id]

  task_role_arn      = []
  task_exec_role_arn = []
  service_role_arn   = ""

  task_policy_arns = var.ecs_task_role_policy_arns
  task_exec_policy_arns = flatten([
    one(aws_iam_policy.task_exec_policy[*].arn),
    var.ecs_task_exec_role_policy_arns,
  ])

  vpc_id          = var.vpc_id
  ecs_cluster_arn = var.ecs_cluster_arn
  subnet_ids      = var.service_subnet_ids
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory

  platform_version                   = "1.4.0"
  propagate_tags                     = "SERVICE"
  assign_public_ip                   = var.service_assign_public_ip
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 10
  enable_ecs_managed_tags            = true
  security_group_enabled             = false

  security_group_description         = ""
  enable_all_egress_rule             = false
  enable_icmp_rule                   = false
  use_alb_security_group             = false
  alb_security_group                 = ""
  use_nlb_cidr_blocks                = false
  nlb_container_port                 = 80
  nlb_cidr_blocks                    = []
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  ordered_placement_strategy         = []
  task_placement_constraints         = []
  service_placement_constraints      = []
  network_mode                       = "awsvpc"
  deployment_controller_type         = "ECS"
  runtime_platform                   = []
  efs_volumes                        = []
  docker_volumes                     = []
  proxy_configuration                = null
  ignore_changes_task_definition     = var.ignore_changes_task_definition
  ignore_changes_desired_count       = var.ignore_changes_desired_count
  capacity_provider_strategies       = []
  service_registries                 = []
  permissions_boundary               = ""
  use_old_arn                        = false
  wait_for_steady_state              = false
  task_definition                    = null
  force_new_deployment               = true
  exec_enabled                       = true
  circuit_breaker_deployment_enabled = false
  circuit_breaker_rollback_enabled   = false
  ephemeral_storage_size             = 0
  role_tags_enabled                  = true
}


# ------------------------------------------------------------------------------
# Service Security Group
# ------------------------------------------------------------------------------
module "service_security_group" {
  source  = "registry.terraform.io/SevenPicoForks/security-group/aws"
  version = "3.0.0"
  context = module.context.self

  vpc_id                     = var.vpc_id
  security_group_name        = [module.context.id]
  security_group_description = "Controls access to ${module.context.id}"

  create_before_destroy = true
  preserve_security_group_id = true // this will cause short service disruption, but will not DESTROY the SG which is more catastrophic
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
    module.ddb_context.enabled ? {
      description              = "Allow egress from service to DocumentDB"
      type                     = "egress"
      protocol                 = "tcp"
      from_port                = var.ddb_port
      to_port                  = var.ddb_port
      source_security_group_id = module.ddb.security_group_id
    } : null
  ] : rule if rule != null]
}
