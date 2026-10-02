variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "techpathway"
}

variable "ecr_repo_backend" {
  type    = string
  default = "techpathway-backend"
}

variable "ecr_repo_frontend" {
  type    = string
  default = "techpathway-frontend"
}
