# ------------------------------------------------------------------------------
# Container Configuration Secrets
# ------------------------------------------------------------------------------
module "configuration_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["configuration"]
}

module "kms_key" {
  source  = "registry.terraform.io/cloudposse/kms-key/aws"
  version = "0.12.1"
  context = module.configuration_meta.context

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  description              = "KMS key for ${module.this.id}"
  enable_key_rotation      = false
  key_usage                = "ENCRYPT_DECRYPT"
}

resource "aws_secretsmanager_secret" "container" {
  count       = module.this.enabled ? 1 : 0
  name_prefix = "${module.configuration_meta.id}-"
  tags        = module.configuration_meta.tags
  description = "Environment Variables for the ${module.this.id_full}"
  kms_key_id  = module.kms_key.key_id
}

resource "aws_secretsmanager_secret_version" "container" {
  count         = module.configuration_meta.enabled ? 1 : 0
  secret_id     = aws_secretsmanager_secret.container[0].id
  secret_string = jsonencode(var.secrets)
}

data "aws_secretsmanager_secret_version" "container" {
  count         = module.configuration_meta.enabled ? 1 : 0
  depends_on    = [aws_secretsmanager_secret_version.container]
  secret_id     = aws_secretsmanager_secret.container[0].id
  version_stage = "AWSCURRENT"
}
