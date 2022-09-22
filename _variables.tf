variable "task_cpu" {
  default = 256
}

variable "task_memory" {
  default = 512
}

variable "ddb_port" {
  type    = number
  default = 27017
}

variable "ddb_username" {
  type    = string
  default = ""
}

variable "ddb_password" {
  type    = string
  default = ""
}

variable "ddb_retention_period" {
  type    = number
  default = 30
}

variable "ddb_allowed_security_groups" {
  type    = list(string)
  default = []
}

variable "ddb_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "enable_nlb" {
  type    = bool
  default = false
}

variable "enable_ddb" {
  type    = bool
  default = false
}

variable "enable_alb" {
  type    = bool
  default = true
}

variable "lb_deletion_protection_enabled" {
  type    = bool
  default = false
}

variable "ecs_additional_load_balancer_mapping" {
  type    = any
  default = []
}

variable "ignore_changes_task_definition" {
  type    = bool
  default = true
}

variable "ignore_changes_desired_count" {
  type = bool
  default = false
}

variable "secrets" {
  type    = map(string)
  default = {}
}

variable "additional_secrets" {
  type    = map(string)
  default = {}
}

variable "container_image" {
  type = string
}

variable "container_port" {
  default = 443
}

variable "service_command" {
  type    = list(string)
  default = []
}

variable "alb_target_group_protocol" {
  default = "HTTPS"
}

variable "alb_http_redirect" {
  type    = bool
  default = false
}

variable "alb_http_enabled" {
  type    = bool
  default = false
}

variable "health_check_path" {
  default = "/health"
}

variable "health_check_matcher" {
  default = "200-399"
}

variable "alb_https_ssl_policy" {
  default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  type    = string
}

variable "nlb_tls_ssl_policy" {
  default = "ELBSecurityPolicy-2016-08"
  type    = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_cloudwatch_log_group_name" {
  type    = string
  default = ""
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "service_subnet_ids" {
  type    = list(string)
  default = []
}

variable "nlb_subnet_ids" {
  type    = list(string)
  default = []
}

variable "acm_certificate_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "access_logs_s3_bucket_id" {
  type    = string
  default = ""
}

variable "service_security_group_rules_map" {
  type    = any
  default = {}
}

variable "alb_security_group_rules_map" {
  type    = any
  default = {}
}

variable "alb_internal" {
  type    = bool
  default = true
}

variable "service_assign_public_ip" {
  type    = bool
  default = false
}

variable "container_entrypoint" {
  default = null
}

variable "container_port_mappings" {
  default = []
}

variable "ecs_task_role_policy_arns" {
  type    = list(string)
  default = []
}

variable "ecs_task_exec_role_policy_arns" {
  type    = list(string)
  default = []
}

variable "ecs_service_role_policy_arns" {
  type    = list(string)
  default = []
}

variable "deployment_artifacts_s3_bucket_id" {
  type    = string
  default = ""
}

variable "deployment_artifacts_s3_bucket_arn" {
  type    = string
  default = ""
}

variable "route53_records_enabled" {
  type    = bool
  default = false
}

variable "route53_zone_id" {
  type    = string
  default = ""
}

variable "cloudwatch_log_expiration_days" { default = 90 }

variable "kms_key_deletion_window_in_days" {
  type    = number
  default = 30
}

variable "kms_key_enable_key_rotation" {
  type    = bool
  default = true
}

variable "pipeline_enabled" {
  type    = bool
  default = true
}
