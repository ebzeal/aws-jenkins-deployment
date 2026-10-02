resource "aws_ecr_repository" "backend" {
  name                 = var.ecr_repo_backend
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags = { Name = var.ecr_repo_backend }
}

resource "aws_ecr_repository" "frontend" {
  name                 = var.ecr_repo_frontend
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags = { Name = var.ecr_repo_frontend }
}
