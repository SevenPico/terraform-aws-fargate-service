# ------------------------------------------------------------------------------
# Continuous Deployment Pipeline Context
# ------------------------------------------------------------------------------
module "pipeline_context" {
  source     = "SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  enabled    = module.context.enabled && var.pipeline_enabled
  attributes = ["pipeline"]
}


# ------------------------------------------------------------------------------
# Continuous Deployment Pipeline Cloudwatch Group
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "pipeline" {
  count             = module.pipeline_context.enabled ? 1 : 0
  name              = "/aws/codebuild/${module.pipeline_context.id}"
  retention_in_days = var.cloudwatch_log_expiration_days
  tags              = module.pipeline_context.tags
}


# ------------------------------------------------------------------------------
# Continuous Deployment Pipeline IAM
# ------------------------------------------------------------------------------
resource "aws_iam_role" "pipeline" {
  count              = module.pipeline_context.enabled ? 1 : 0
  name               = "${module.pipeline_context.id}-role"
  assume_role_policy = one(data.aws_iam_policy_document.pipeline_assume_role_policy[*].json)
  description        = "Allows Code Pipeline service to make calls to run tasks, scale, etc."
  tags               = module.pipeline_context.tags
}

resource "aws_iam_role_policy" "pipeline" {
  count  = module.pipeline_context.enabled ? 1 : 0
  name   = "${module.pipeline_context.id}-policy"
  role   = one(aws_iam_role.pipeline[*].id)
  policy = one(data.aws_iam_policy_document.pipeline_policy[*].json)
}

data "aws_iam_policy_document" "pipeline_assume_role_policy" {
  count   = module.pipeline_context.enabled ? 1 : 0
  version = "2012-10-17"
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

# FIXME - likely doesn't need all these permissions
data "aws_iam_policy_document" "pipeline_policy" {
  count   = module.pipeline_context.enabled ? 1 : 0
  version = "2012-10-17"
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
      "s3:Get*",
      "s3:List*",
      "s3:Put*"
    ]
    effect = "Allow"
    resources = [
      var.deployment_artifacts_s3_bucket_arn,
      "${var.deployment_artifacts_s3_bucket_arn}/*",
    ]
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


# ------------------------------------------------------------------------------
# Continuous Deployment Pipeline
# ------------------------------------------------------------------------------
resource "aws_codepipeline" "service" {
  count    = module.pipeline_context.enabled ? 1 : 0
  name     = module.pipeline_context.id
  role_arn = one(aws_iam_role.pipeline[*].arn)
  tags     = module.pipeline_context.tags

  artifact_store {
    location = var.deployment_artifacts_s3_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["source"]
      configuration = {
        S3Bucket             = var.deployment_artifacts_s3_bucket_id
        S3ObjectKey          = "${module.context.id}.zip"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["source"]
      version         = "1"

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = module.context.id
        FileName    = "${module.context.id}.json"
      }
    }
  }
}

