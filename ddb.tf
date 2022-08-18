# ------------------------------------------------------------------------------
# Document Database Context
# ------------------------------------------------------------------------------
module "ddb_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.context.self
  attributes = ["ddb"]
  enabled    = module.context.enabled && var.enable_ddb
}

module "ddb_dns_context" {
  source  = "app.terraform.io/SevenPico/context/null"
  version = "1.0.1"
  context = module.ddb_context.self
  enabled = module.ddb_context.enabled && var.route53_records_enabled
  name    = "${module.context.name}-ddb"
}

module "ddb_reader_dns_context" {
  source  = "app.terraform.io/SevenPico/context/null"
  version = "1.0.1"
  context = module.ddb_context.self
  enabled = module.ddb_context.enabled && var.route53_records_enabled
  name    = "${module.context.name}-ddb-reader"
}



# ------------------------------------------------------------------------------
# KMS Key
# ------------------------------------------------------------------------------
module "ddb_kms_key" {
  source  = "app.terraform.io/SevenPico/kms-key/aws"
  version = "0.12.1.1"
  context = module.ddb_context.self

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = var.kms_key_deletion_window_in_days
  description              = "KMS key for ${module.ddb_context.id}"
  enable_key_rotation      = var.kms_key_enable_key_rotation
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy                   = ""
}


# ------------------------------------------------------------------------------
# Document Database
# ------------------------------------------------------------------------------
module "ddb" {
  source  = "registry.terraform.io/cloudposse/documentdb-cluster/aws"
  version = "0.13.0"
  context = module.ddb_context.self

  subnet_ids                      = var.service_subnet_ids
  vpc_id                          = var.vpc_id
  allowed_security_groups         = concat([module.service_security_group.id], var.ddb_allowed_security_groups)
  db_port                         = var.ddb_port
  kms_key_id                      = module.ddb_kms_key.key_id
  master_username                 = var.ddb_username
  master_password                 = var.ddb_password
  retention_period                = var.ddb_retention_period
  cluster_dns_name                = ""
  reader_dns_name                 = ""
  zone_id                         = ""
  allowed_cidr_blocks             = []
  apply_immediately               = true
  auto_minor_version_upgrade      = true
  cluster_family                  = "docdb4.0"
  cluster_size                    = 1
  skip_final_snapshot             = true
  storage_encrypted               = true
  snapshot_identifier             = ""
  deletion_protection             = false
  enabled_cloudwatch_logs_exports = ["audit"]
  engine                          = "docdb"
  engine_version                  = ""
  instance_class                  = "db.r5.large"
  preferred_backup_window         = "07:00-09:00"
  preferred_maintenance_window    = "Mon:22:00-Mon:23:00"
  cluster_parameters = [{
    apply_method = "pending-reboot"
    name         = "tls"
    value        = "enabled"
  }]
}


# ------------------------------------------------------------------------------
# Document Database DNS
# ------------------------------------------------------------------------------
resource "aws_route53_record" "ddb" {
  count   = module.ddb_dns_context.enabled ? 1 : 0
  zone_id = var.route53_zone_id
  type    = "CNAME"
  name    = module.ddb_dns_context.descriptors["FQDN"]
  records = [module.ddb.endpoint]
  ttl     = 300
}

resource "aws_route53_record" "ddb_reader" {
  count   = module.ddb_reader_dns_context.enabled ? 1 : 0
  zone_id = var.route53_zone_id
  type    = "CNAME"
  name    = module.ddb_reader_dns_context.descriptors["FQDN"]
  records = [module.ddb.reader_endpoint]
  ttl     = 300
}
