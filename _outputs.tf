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

output "secrets_kms_key_arn" {
  value = module.kms_key.key_arn
}

output "ddb_port" {
  value = var.ddb_port
}

output "container_port" {
  value = var.container_port
}

output "ddb_enabled" {
  value = module.ddb_meta.enabled
}

output "id" {
  value = module.this.id
}

output "stage" {
  value = module.this.stage
}

output "enabled" {
  value = module.this.enabled
}

output "tags" {
  value = module.this.tags
}

output "context" {
  value = module.this.context
}
