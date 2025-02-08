variable "aws_region" {
  description = "The AWS region where the EKS cluster will be created"
  type        = string
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "fubara-eks-cluster"
}

variable "eks_version" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "The ID of the default VPC"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the default VPC"
  type        = list(string)
  default     = []
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  default     = "SecurePass123"
}
