output "ecr_repo_name" {
  value = module.k8-infrastructure.ecr_repo_name
}

output "eks_cluster_name" {
  value = module.k8-infrastructure.eks_cluster_name
}

output "region" {
  value = local.region
}
