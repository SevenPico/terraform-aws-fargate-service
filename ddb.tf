# ------------------------------------------------------------------------------
# Document Database (Optional)
# ------------------------------------------------------------------------------
module "ddb_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["ddb"]
  enabled    = module.this.enabled && var.enable_ddb
}

resource "aws_kms_key" "ddb" {
  count                   = module.ddb_meta.enabled ? 1 : 0
  description             = "${module.ddb_meta.id}-key"
  deletion_window_in_days = 30
  tags                    = module.ddb_meta.tags
}

module "ddb" {
  source  = "registry.terraform.io/cloudposse/documentdb-cluster/aws"
  version = "0.13.0"
  context = module.ddb_meta.context

  subnet_ids                      = var.service_subnet_ids
  vpc_id                          = var.vpc_id
  allowed_security_groups         = concat([module.service_security_group.id], var.ddb_allowed_security_groups)
  db_port                         = var.ddb_port
  kms_key_id                      = one(aws_kms_key.ddb[*].arn)
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
# DDB : DNS Record
# ------------------------------------------------------------------------------
module "ddb_dns_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = var.dns_context
  enabled = module.ddb_meta.enabled && var.route53_records_enabled
  attributes = ["${module.this.name}-ddb"]
}

module "ddb_reader_dns_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = var.dns_context
  enabled = module.ddb_meta.enabled && var.route53_records_enabled
  attributes = ["${module.this.name}-ddb-reader"]
}

resource "aws_route53_record" "ddb" {
  count   = module.ddb_dns_meta.enabled ? 1 : 0
  zone_id = var.route53_zone_id
  type    = "CNAME"
  name    = module.ddb_dns_meta.descriptors["FQDN"]
  records = [module.ddb.endpoint]
  ttl     = 300
}

resource "aws_route53_record" "ddb_reader" {
  count   = module.ddb_reader_dns_meta.enabled ? 1 : 0
  zone_id = var.route53_zone_id
  type    = "CNAME"
  name    = module.ddb_reader_dns_meta.descriptors["FQDN"]
  records = [module.ddb.reader_endpoint]
  ttl     = 300
}
