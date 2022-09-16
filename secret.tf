# ------------------------------------------------------------------------------
# Service Configuration Context
# ------------------------------------------------------------------------------
module "service_configuration_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.context.self
#  attributes = ["configuration"]
}


# --------------------------------------------------------------------------
# Service Configuration
# --------------------------------------------------------------------------
module "service_configuration" {
  source  = "app.terraform.io/SevenPico/secret/aws"
  version = "1.0.7"
  context = module.service_configuration_context.self

  create_sns                      = false
  description                     = "Secrets and environment variables for ${module.context.id}"
  kms_key_deletion_window_in_days = var.kms_key_deletion_window_in_days
  kms_key_enable_key_rotation     = var.kms_key_enable_key_rotation
  secret_ignore_changes           = false
  secret_read_principals          = {}
  secret_string                   = jsonencode(var.secrets)
  sns_pub_principals              = null
  sns_sub_principals              = null
}
