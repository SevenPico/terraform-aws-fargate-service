# ------------------------------------------------------------------------------
# Service Autoscaling Contexts
# ------------------------------------------------------------------------------
module "autoscale_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.context.self
  attributes = ["autoscale"]
  enabled    = module.context.enabled && var.autoscale_enabled
}

module "alarms_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.context.self
  attributes = ["alarms"]
  enabled    = module.context.enabled && var.alarms_enabled
}


# ------------------------------------------------------------------------------
# Service Autoscaling
# ------------------------------------------------------------------------------
module "autoscale" {
  source  = "registry.terraform.io/cloudposse/ecs-cloudwatch-autoscaling/aws"
  version = "0.7.2"
  context = module.autoscale_context

  service_name          = module.service.service_name
  cluster_name          = var.ecs_cluster_name
  min_capacity          = var.autoscale_min_capacity
  max_capacity          = var.autoscale_max_capacity
  scale_down_adjustment = var.autoscale_scale_down_adjustment
  scale_down_cooldown   = var.autoscale_scale_down_cooldown
  scale_up_adjustment   = var.autoscale_scale_up_adjustment
  scale_up_cooldown     = var.autoscale_scale_up_cooldown
}


# ------------------------------------------------------------------------------
# Service Utilization Alarms
# ------------------------------------------------------------------------------
locals {
  cpu_utilization_high_alarm_actions    = var.autoscale_enabled && var.autoscale_dimension == "cpu" ? module.autoscale.scale_up_policy_arn : ""
  cpu_utilization_low_alarm_actions     = var.autoscale_enabled && var.autoscale_dimension == "cpu" ? module.autoscale.scale_down_policy_arn : ""
  memory_utilization_high_alarm_actions = var.autoscale_enabled && var.autoscale_dimension == "memory" ? module.autoscale.scale_up_policy_arn : ""
  memory_utilization_low_alarm_actions  = var.autoscale_enabled && var.autoscale_dimension == "memory" ? module.autoscale.scale_down_policy_arn : ""
}

module "sns_alarms" {
  source  = "registry.terraform.io/cloudposse/ecs-cloudwatch-sns-alarms/aws"
  version = "0.12.1"
  context = module.alarms_context.self

  cluster_name = var.ecs_cluster_name
  service_name = module.service.service_name

  cpu_utilization_high_threshold          = var.alarms_cpu_utilization_high_threshold
  cpu_utilization_high_evaluation_periods = var.alarms_cpu_utilization_high_evaluation_periods
  cpu_utilization_high_period             = var.alarms_cpu_utilization_high_period

  cpu_utilization_high_alarm_actions = compact(
    concat(
      var.alarms_cpu_utilization_high_alarm_actions,
      [local.cpu_utilization_high_alarm_actions],
    )
  )

  cpu_utilization_high_ok_actions = var.alarms_cpu_utilization_high_ok_actions

  cpu_utilization_low_threshold          = var.alarms_cpu_utilization_low_threshold
  cpu_utilization_low_evaluation_periods = var.alarms_cpu_utilization_low_evaluation_periods
  cpu_utilization_low_period             = var.alarms_cpu_utilization_low_period

  cpu_utilization_low_alarm_actions = compact(
    concat(
      var.alarms_cpu_utilization_low_alarm_actions,
      [local.cpu_utilization_low_alarm_actions],
    )
  )

  cpu_utilization_low_ok_actions = var.alarms_cpu_utilization_low_ok_actions

  memory_utilization_high_threshold          = var.alarms_memory_utilization_high_threshold
  memory_utilization_high_evaluation_periods = var.alarms_memory_utilization_high_evaluation_periods
  memory_utilization_high_period             = var.alarms_memory_utilization_high_period

  memory_utilization_high_alarm_actions = compact(
    concat(
      var.alarms_memory_utilization_high_alarm_actions,
      [local.memory_utilization_high_alarm_actions],
    )
  )

  memory_utilization_high_ok_actions = var.alarms_memory_utilization_high_ok_actions

  memory_utilization_low_threshold          = var.alarms_memory_utilization_low_threshold
  memory_utilization_low_evaluation_periods = var.alarms_memory_utilization_low_evaluation_periods
  memory_utilization_low_period             = var.alarms_memory_utilization_low_period

  memory_utilization_low_alarm_actions = compact(
    concat(
      var.alarms_memory_utilization_low_alarm_actions,
      [local.memory_utilization_low_alarm_actions],
    )
  )

  memory_utilization_low_ok_actions = var.alarms_memory_utilization_low_ok_actions
}
