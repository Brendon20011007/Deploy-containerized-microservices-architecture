variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository containing the service images"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 