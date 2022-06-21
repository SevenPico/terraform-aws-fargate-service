# ------------------------------------------------------------------------------
# Network Load Balancer
# ------------------------------------------------------------------------------
module "nlb_meta" {
  source          = "registry.terraform.io/cloudposse/label/null"
  version         = "0.25.0"
  context         = module.this.context
  enabled         = module.this.context.enabled && var.enable_nlb
  attributes      = ["pvt", "nlb"]
  id_length_limit = 32
}

module "nlb_tgt_meta" {
  source          = "registry.terraform.io/cloudposse/label/null"
  version         = "0.25.0"
  context         = module.nlb_meta.context
  attributes      = ["tgt"]
}

module "nlb" {
  count   = module.nlb_meta.enabled ? 1 : 0 # count because module does not destroy all it's resources
  source  = "registry.terraform.io/cloudposse/nlb/aws"
  version = "0.8.2"
  context = module.nlb_meta.context

  subnet_ids                        = var.nlb_subnet_ids
  vpc_id                            = var.vpc_id
  access_logs_enabled               = var.access_logs_s3_bucket_id != ""
  access_logs_s3_bucket_id          = var.access_logs_s3_bucket_id
  access_logs_prefix                = module.nlb_meta.id
  certificate_arn                   = var.acm_certificate_arn
  deletion_protection_enabled       = false
  deregistration_delay              = 300
  enable_glacier_transition         = var.enable_glacier_transition
  expiration_days                   = var.expiration_days
  glacier_transition_days           = var.glacier_transition_days
  health_check_enabled              = true
  health_check_interval             = 10
  health_check_path                 = var.health_check_path
  health_check_port                 = null
  health_check_protocol             = "HTTPS"
  health_check_threshold            = 2
  internal                          = true
  ip_address_type                   = "ipv4"

  lifecycle_rule_enabled                  = var.lifecycle_rule_enabled
  nlb_access_logs_s3_bucket_force_destroy = var.force_destroy
  noncurrent_version_expiration_days      = var.noncurrent_version_expiration_days
  noncurrent_version_transition_days      = var.noncurrent_version_transition_days
  standard_transition_days                = var.standard_transition_days
  target_group_additional_tags            = {}
  target_group_name                       = var.enable_nlb ? module.nlb_tgt_meta.id : "null"
  target_group_port                       = 443
  target_group_target_type                = "alb"
  tcp_enabled                             = false
  tls_enabled                             = true
  tcp_port                                = 443
  tls_port                                = 443
  tls_ssl_policy                          = "ELBSecurityPolicy-2016-08"
  udp_enabled                             = false
  udp_port                                = 53
}

resource "aws_lb_target_group_attachment" "nlb" {
  count            = module.nlb_meta.enabled ? 1 : 0
  target_group_arn = one(module.nlb[*].default_target_group_arn)
  target_id        = module.alb.alb_arn
}
