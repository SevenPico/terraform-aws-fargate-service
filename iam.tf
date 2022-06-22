
module "task_role_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["task-role"]
}

module "task_exec_role_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["task-exec-role"]
}

module "service_role_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["service-role"]
}


# ------------------------------------------------------------------------------
# ECS Task Role (or Container Role)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "task_role" {
  count = module.task_role_meta.enabled ? 1 : 0
  name  = module.task_role_meta.id
  tags  = module.task_role_meta.tags

  assume_role_policy  = one(data.aws_iam_policy_document.task_assume_role_policy_doc[*].json)
  managed_policy_arns = var.ecs_task_role_policy_arns
}

data "aws_iam_policy_document" "task_assume_role_policy_doc" {
  count = module.task_role_meta.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
      type = "Service"
    }
  }

  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "SsmMessages"
  }
}


# ------------------------------------------------------------------------------
# ECS Task Execution Role
# ------------------------------------------------------------------------------
resource "aws_iam_role" "task_exec_role" {
  count = module.task_exec_role_meta.enabled ? 1 : 0
  name  = module.task_exec_role_meta.id
  tags  = module.task_exec_role_meta.tags

  assume_role_policy = one(data.aws_iam_policy_document.task_assume_role_policy_doc[*].json)

  managed_policy_arns = flatten([
    var.ecs_task_exec_role_policy_arns,
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ])

  inline_policy {
    name   = "${module.task_exec_role_meta.id}-policy"
    policy = one(data.aws_iam_policy_document.task_exec_role_policy_doc[*].json)
  }
}

data "aws_iam_policy_document" "task_exec_role_policy_doc" {
  count = module.task_exec_role_meta.enabled ? 1 : 0

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

  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}


# ------------------------------------------------------------------------------
# ECS Service Role
# ------------------------------------------------------------------------------
resource "aws_iam_role" "service_role" {
  count = module.service_role_meta.enabled ? 1 : 0
  name  = module.service_role_meta.id
  tags  = module.service_role_meta.tags

  assume_role_policy = one(data.aws_iam_policy_document.service_assume_role_policy_doc[*].json)

  managed_policy_arns = var.ecs_service_role_policy_arns

  inline_policy {
    name   = "${module.service_role_meta.id}-policy"
    policy = one(data.aws_iam_policy_document.service_role_policy_doc[*].json)
  }
}


data "aws_iam_policy_document" "service_assume_role_policy_doc" {
  count = module.service_role_meta.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = [
        "events.amazonaws.com",
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }
    sid = "EcsCloudwatchEventsAssumeRole"
  }

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["codepipeline.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "service_role_policy_doc" {
  count = module.service_role_meta.enabled ? 1 : 0

  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:RunTask",
      "ecs:UpdateService"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test = "StringLike"
      values = [
        "ecs-tasks.amazonaws.com",
        "ec2.amazonaws.com"
      ]
      variable = "iam:PassedToService"
    }
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:DeleteLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "ec2:Describe*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "ActiveTracing"
  }
}
