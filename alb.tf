# ------------------------------------------------------------------------------
# Application Load Balancer Contexts
# ------------------------------------------------------------------------------
module "alb_context" {
  source          = "app.terraform.io/SevenPico/context/null"
  version         = "1.0.1"
  context         = module.context.self
  enabled         = module.context.enabled && var.enable_alb
  attributes      = ["pvt", "alb"]
  id_length_limit = 32
}

module "alb_dns_context" {
  source  = "app.terraform.io/SevenPico/context/null"
  version = "1.0.1"
  context = module.alb_context.self
  enabled = module.alb_context.enabled && var.route53_records_enabled
  name    = "${module.context.name}-alb"
}


module "alb_tgt_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.alb_context.self
  attributes = ["tgt"]
}


# ------------------------------------------------------------------------------
# Application Load Balancer
# ------------------------------------------------------------------------------
module "alb" {
  count   = module.alb_context.enabled ? 1 : 0
  source  = "app.terraform.io/SevenPico/alb/aws"
  version = "1.4.0.1"
  context = module.alb_context.self

  access_logs_enabled               = var.access_logs_s3_bucket_id != ""
  access_logs_prefix                = module.alb_context.id
  access_logs_s3_bucket_id          = var.access_logs_s3_bucket_id
  additional_certs                  = []
  certificate_arn                   = var.acm_certificate_arn
  cross_zone_load_balancing_enabled = true
  default_target_group_enabled      = true
  deletion_protection_enabled       = var.lb_deletion_protection_enabled
  deregistration_delay              = 20
  drop_invalid_header_fields        = false
  health_check_healthy_threshold    = 2
  health_check_interval             = 300
  health_check_matcher              = var.health_check_matcher
  health_check_path                 = var.health_check_path
  health_check_port                 = var.container_port
  health_check_protocol             = null
  health_check_timeout              = 120
  health_check_unhealthy_threshold  = 2
  http2_enabled                     = true
  http_enabled                      = var.alb_http_enabled
  http_ingress_cidr_blocks          = ["0.0.0.0/0"]
  http_ingress_prefix_list_ids      = []
  http_port                         = 80
  http_redirect                     = var.alb_http_redirect
  https_enabled                     = true
  https_ingress_cidr_blocks         = ["0.0.0.0/0"]
  https_ingress_prefix_list_ids     = []
  https_port                        = 443
  https_ssl_policy                  = var.alb_https_ssl_policy
  idle_timeout                      = 60
  internal                          = var.alb_internal #true
  ip_address_type                   = "ipv4"
  listener_http_fixed_response      = null
  listener_https_fixed_response     = null
  load_balancer_name                = ""
  load_balancer_name_max_length     = 32
  security_group_enabled            = true
  security_group_ids                = [module.alb_security_group.id]
  slow_start                        = null
  stickiness                        = null
  subnet_ids                        = var.service_subnet_ids
  target_group_additional_tags      = {}
  target_group_name                 = module.alb_tgt_context.id
  target_group_name_max_length      = 32
  target_group_port                 = var.container_port
  target_group_protocol             = var.alb_target_group_protocol
  target_group_protocol_version     = "HTTP1"
  target_group_target_type          = "ip"
  vpc_id                            = var.vpc_id
}


# ------------------------------------------------------------------------------
# Application Load Balancer Security Group
# ------------------------------------------------------------------------------
module "alb_security_group" {
  source  = "registry.terraform.io/cloudposse/security-group/aws"
  version = "0.4.3"
  context = module.alb_context.self

  vpc_id                     = var.vpc_id
  security_group_name        = [module.alb_context.id]
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


# ------------------------------------------------------------------------------
# Application Load Balancer DNS
# ------------------------------------------------------------------------------
resource "aws_route53_record" "alb" {
  count   = module.alb_dns_context.enabled ? 1 : 0
  zone_id = var.route53_zone_id
  type    = "CNAME"
  name    = module.alb_dns_context.dns_name
  records = [one(module.alb[*].alb_dns_name)]
  ttl     = 300
}
