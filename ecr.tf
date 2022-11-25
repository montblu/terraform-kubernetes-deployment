resource "aws_ecr_repository" "main" {
  count = var.ecr_create ? 1 : 0

  name = "${var.name_prefix}-${var.name}"

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  count = var.ecr_create ? 1 : 0

  repository = aws_ecr_repository.main[0].name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${var.ecr_number_of_images_to_keep} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.ecr_number_of_images_to_keep}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

  depends_on = [
    aws_ecr_repository.main
  ]
}
