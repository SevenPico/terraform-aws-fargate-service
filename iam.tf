# ------------------------------------------------------------------------------
# ECS Task Execution Role
# ------------------------------------------------------------------------------
module "task_exec_policy_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["task-exec-policy"]
}

resource "aws_iam_policy" "task_exec_policy" {
  count       = module.task_exec_policy_meta.enabled ? 1 : 0
  policy      = one(data.aws_iam_policy_document.task_exec_policy_doc[*].json)
  name        = module.task_exec_policy_meta.id
  description = ""
}

data "aws_iam_policy_document" "task_exec_policy_doc" {
  count = module.task_exec_policy_meta.enabled ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [one(aws_secretsmanager_secret.container[*].arn)]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [module.kms_key.key_arn]
  }
}
