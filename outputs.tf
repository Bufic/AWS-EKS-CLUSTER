output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}


output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.vpc_id
}

output "subnet_ids" {
  description = "The subnet IDs in which the EKS cluster will run"
  value       = var.subnet_ids
}



output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "grafana_url" {
  description = "Grafana UI URL"
  value       = "http://${helm_release.kube_prometheus_stack.metadata[0].name}.monitoring.svc.cluster.local:80"
}
