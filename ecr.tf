resource "aws_ecr_repository" "main" {
  count = var.deployment.create_ecr ? 1 : 0

  name = local.resource_name

  image_scanning_configuration {
    scan_on_push = var.deployment.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = var.deployment.ecr_encryption_type
  }

}

resource "aws_ecr_lifecycle_policy" "main" {
  count = var.deployment.create_ecr ? 1 : 0

  repository = aws_ecr_repository.main[0].name
  policy     = var.ecr_lifecycle_policy
}

# allow pull from all other accounts
data "aws_iam_policy_document" "main" {
  count = var.deployment.create_ecr && length(var.ecr_allowed_aws_accounts) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = var.ecr_allowed_aws_accounts
    content {
      sid    = "Pull only for ${statement.value}"
      effect = "Allow"
      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${statement.value}:root"
        ]
      }
      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
      ]
    }
  }
}
resource "aws_ecr_repository_policy" "main" {
  count = var.deployment.create_ecr && length(var.ecr_allowed_aws_accounts) > 0 ? 1 : 0

  repository = aws_ecr_repository.main[0].name
  policy     = data.aws_iam_policy_document.main[0].json
}