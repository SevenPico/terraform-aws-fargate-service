# ------------------------------------------------------------------------------
# Application Load Balancer
# ------------------------------------------------------------------------------
module "alb_meta" {
  source          = "registry.terraform.io/cloudposse/label/null"
  version         = "0.25.0"
  context         = module.this.context
  attributes      = ["pvt", "alb"]
  id_length_limit = 32
}

module "alb_tgt_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.alb_meta.context
  attributes = ["tgt"]
}

module "alb" {
  source  = "registry.terraform.io/cloudposse/alb/aws"
  version = "0.36.0"
  context = module.alb_meta.context

  access_logs_enabled                = var.access_logs_s3_bucket_id != ""
  access_logs_prefix                 = module.alb_meta.id
  access_logs_s3_bucket_id           = var.access_logs_s3_bucket_id
  certificate_arn                    = var.acm_certificate_arn
  deregistration_delay               = 20
  enable_glacier_transition          = var.enable_glacier_transition
  expiration_days                    = var.expiration_days
  glacier_transition_days            = var.glacier_transition_days
  health_check_interval              = 300
  health_check_path                  = var.health_check_path
  health_check_port                  = var.container_port
  health_check_timeout               = 120
  health_check_matcher               = var.health_check_matcher
  http_enabled                       = false
  https_enabled                      = true
  https_port                         = 443
  http_port                          = 80
  https_ssl_policy                   = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  internal                           = var.alb_internal #true
  noncurrent_version_expiration_days = var.noncurrent_version_expiration_days
  noncurrent_version_transition_days = var.noncurrent_version_transition_days
  security_group_ids                 = [module.alb_security_group.id]
  standard_transition_days           = var.standard_transition_days
  subnet_ids                         = var.service_subnet_ids
  target_group_name                  = module.alb_tgt_meta.id
  target_group_port                  = var.container_port
  target_group_protocol              = var.alb_target_group_protocol
  vpc_id                             = var.vpc_id
}


# ------------------------------------------------------------------------------
# Application Load Balancer : Security Group
# ------------------------------------------------------------------------------
module "alb_security_group" {
  source  = "registry.terraform.io/cloudposse/security-group/aws"
  version = "0.4.3"
  context = module.alb_meta.context

  vpc_id                     = var.vpc_id
  security_group_name        = [module.alb_meta.id]
  security_group_description = "Controls access to the ALB"
  create_before_destroy      = true
  rules_map                  = var.alb_security_group_rules_map
  rules = [
    {
      # FIXME - egress not needed, check
      # FIXME - key on each rule
      type        = "egress"
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
