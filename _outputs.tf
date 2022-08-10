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

output "alb_dns_alias" {
  value = module.alb_dns_meta.descriptors["FQDN"]
}

output "nlb_dns_alias" {
  value = module.nlb_dns_meta.descriptors["FQDN"]
}

output "nlb_dns_name" {
  value = one(module.nlb[*].nlb_dns_name)
}

output "nlb_zone_id" {
  value = one(module.nlb[*].nlb_zone_id)
}

output "alb_url" {
  value = "https://${module.alb_dns_meta.descriptors["FQDN"]}:${var.container_port}"
}

output "ddb_url" {
  value = "mongodb://${var.ddb_username}:${var.ddb_password}@${module.ddb_dns_meta.descriptors["FQDN"]}:${var.ddb_port}/default?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

output "ddb_dns_name" {
  value = module.ddb.endpoint
}

output "ddb_reader_dns_name" {
  value = module.ddb.reader_endpoint
}

output "id" {
  value = module.this.id
}

output "container_port" {
  value = var.container_port
}

output "ddb_port" {
  value = var.ddb_port
}

output "secrets_kms_key_arn" {
  value = module.kms_key.key_arn
}

output "ddb_enabled" {
  value = module.ddb_meta.enabled
}

output "alb_http_listener_arn" {
  value = one(module.alb[*].http_listener_arn)
}

output "alb_https_listener_arn" {
  value = one(module.alb[*].https_listener_arn)
}
