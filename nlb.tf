# ------------------------------------------------------------------------------
# Network Load Balancer Context
# ------------------------------------------------------------------------------
module "nlb_context" {
  source          = "app.terraform.io/SevenPico/context/null"
  version         = "1.0.2"
  context         = module.context.self
  enabled         = module.context.enabled && var.enable_nlb
  attributes      = ["pvt", "nlb"]
  id_length_limit = 32
}

module "nlb_tgt_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.2"
  context    = module.nlb_context.self
  attributes = ["tgt"]
}

module "nlb_dns_context" {
  source  = "app.terraform.io/SevenPico/context/null"
  version = "1.0.2"
  context = module.nlb_context.self
  name    = "${module.context.name}-nlb"
  enabled = module.nlb_context.enabled && var.route53_records_enabled
}


# ------------------------------------------------------------------------------
# Network Load Balancer
# ------------------------------------------------------------------------------
module "nlb" {
  count   = module.nlb_context.enabled ? 1 : 0 # count because module does not destroy all it's resources
  source  = "app.terraform.io/SevenPico/nlb/aws"
  version = "0.8.2.2"
  context = module.nlb_context.self

  access_logs_enabled               = var.access_logs_s3_bucket_id != ""
  access_logs_prefix                = "${data.aws_caller_identity.current.account_id}/${module.nlb_context.id}"
  access_logs_s3_bucket_id          = var.access_logs_s3_bucket_id
  certificate_arn                   = var.acm_certificate_arn
  create_default_target_group       = true
  cross_zone_load_balancing_enabled = true
  deletion_protection_enabled       = var.lb_deletion_protection_enabled
  deregistration_delay              = 300
  health_check_enabled              = true
  health_check_interval             = 10
  health_check_path                 = var.health_check_path
  health_check_port                 = null
  health_check_protocol             = "HTTPS"
  health_check_threshold            = 2
  internal                          = false
  ip_address_type                   = "ipv4"
  subnet_ids                        = var.nlb_subnet_ids
  target_group_additional_tags      = {}
  target_group_name                 = var.enable_nlb ? module.nlb_tgt_context.id : "null"
  target_group_port                 = 443
  target_group_target_type          = "alb"
  tcp_enabled                       = true
  tcp_port                          = 443
  tls_enabled                       = false
  tls_port                          = 443
  tls_ssl_policy                    = var.nlb_tls_ssl_policy
  udp_enabled                       = false
  udp_port                          = 53
  vpc_id                            = var.vpc_id
}

resource "aws_lb_target_group_attachment" "nlb" {
  count            = module.nlb_context.enabled ? 1 : 0
  target_group_arn = one(module.nlb[*].default_target_group_arn)
  target_id        = one(module.alb[*].alb_arn)
}


# ------------------------------------------------------------------------------
# Network Load Balancer DNS Record
# ------------------------------------------------------------------------------
resource "aws_route53_record" "nlb" {
  count   = module.nlb_dns_context.enabled ? 1 : 0
  zone_id = var.route53_zone_id
  name    = module.nlb_dns_context.dns_name
  type    = "A"
  alias {
    name                   = one(module.nlb[*].nlb_dns_name)
    zone_id                = one(module.nlb[*].nlb_zone_id)
    evaluate_target_health = true
  }
}

