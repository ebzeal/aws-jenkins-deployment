variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "techpathway"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "key_name" {
  type    = string
  default = "techpathway-jenkins-key"
}

variable "ssh_allowed_cidr" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR(s) allowed to SSH into Jenkins. Lock to your own IP, e.g. [\"203.0.113.10/32\"]"
}
