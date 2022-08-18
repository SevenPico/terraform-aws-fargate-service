# ------------------------------------------------------------------------------
# ECS Task Execution Role Context
# ------------------------------------------------------------------------------
module "task_exec_policy_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.context.self
  attributes = ["task-exec-policy"]
}


# ------------------------------------------------------------------------------
# ECS Task Execution Role Context
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "task_exec_policy" {
  count       = module.task_exec_policy_context.enabled ? 1 : 0
  policy      = one(data.aws_iam_policy_document.task_exec_policy_doc[*].json)
  name        = module.task_exec_policy_context.id
  description = ""
}

data "aws_iam_policy_document" "task_exec_policy_doc" {
  count = module.task_exec_policy_context.enabled ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [module.service_configuration.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [module.service_configuration.kms_key_arn]
  }
}
