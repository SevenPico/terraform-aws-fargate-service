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
  value = module.alb.alb_dns_name
}

output "nlb_dns_name" {
  value = one(module.nlb[*].nlb_dns_name)
}

output "ddb_dns_name" {
  value = module.ddb.endpoint
}

output "ddb_reader_dns_name" {
  value = module.ddb.reader_endpoint
}
