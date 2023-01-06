output "nlb_arn" {
  value = one(module.nlb[*].nlb_arn)
}

output "service_security_group_id" {
  value = module.service_security_group.id
}

output "alb_security_group_id" {
  value = module.alb_security_group.id
}

output "ddb_security_group_id" {
  value = module.ddb.security_group_id
}

output "alb_dns_name" {
  value = one(module.alb[*].alb_dns_name)
}

output "alb_dns_route53_name" {
  value = join("", aws_route53_record.alb[*].name)
}

output "nlb_dns_route53_name" {
  value = join("", aws_route53_record.nlb[*].name)
}

output "nlb_dns_name" {
  value = one(module.nlb[*].nlb_dns_name)
}

output "nlb_zone_id" {
  value = one(module.nlb[*].nlb_zone_id)
}

output "alb_url" {
  value = "https://${join("", aws_route53_record.alb[*].name)}:${var.container_port}"
}

output "ddb_url" {
  value = "mongodb://${var.ddb_username}:${var.ddb_password}@${join("", aws_route53_record.ddb[*].name)}:${var.ddb_port}/default?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

output "ddb_dns_name" {
  value = module.ddb.endpoint
}

output "ddb_dns_route53_name" {
  value = join("", aws_route53_record.ddb[*].name)
}

output "ddb_reader_dns_name" {
  value = module.ddb.reader_endpoint
}

output "ddb_reader_dns_route53_name" {
  value = join("", aws_route53_record.ddb_reader[*].name)
}

output "id" {
  value = module.context.id
}

output "container_port" {
  value = var.container_port
}

output "ddb_port" {
  value = var.ddb_port
}

output "secrets_kms_key_arn" {
  value = module.service_configuration.kms_key_arn
}

output "ddb_enabled" {
  value = module.ddb_context.enabled
}

output "alb_http_listener_arn" {
  value = one(module.alb[*].http_listener_arn)
}

output "alb_https_listener_arn" {
  value = one(module.alb[*].https_listener_arn)
}

output "alb_http_redirect_listener_arn" {
  value = one(module.alb[*].http_redirect_listener_arn)
}

output "service_name" {
  value = module.service.service_name
}

output "container_name" {
  value = local.container_name
}

output "alb_target_group_arn" {
  value = try(module.alb[0].default_target_group_arn, "")
}
