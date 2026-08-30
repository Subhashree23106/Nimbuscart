variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "nimbuscart"
}

variable "web_vpc_cidr" {
  description = "CIDR for Web VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_vpc_cidr" {
  description = "CIDR for App VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "data_vpc_cidr" {
  description = "CIDR for Data VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)

  default = [
    "ap-south-1a",
    "ap-south-1b"
  ]
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "nimbuscart-key"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "nimbus"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "NimbusCartDB2026!"
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/nimbuscart.pub"
}

variable "ecr_repository_url" {
  description = "ECR repository URL for NimbusCart API"
  type        = string
  default     = "180840261930.dkr.ecr.ap-south-1.amazonaws.com/nimbuscart-api"
}

variable "api_image_tag" {
  description = "NimbusCart API Docker image tag"
  type        = string
  default     = "1.0"
}
