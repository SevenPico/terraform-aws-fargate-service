# ------------------------------------------------------------------------------
# Service Configuration Context
# ------------------------------------------------------------------------------
module "service_configuration_context" {
  source  = "SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
  #  attributes = ["configuration"]
}


# --------------------------------------------------------------------------
# Service Configuration
# --------------------------------------------------------------------------
module "service_configuration" {
  source  = "SevenPico/secret/aws"
  version = "3.1.0"
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
