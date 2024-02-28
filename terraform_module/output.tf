output "ecr_repo_name" {
  value = aws_ecr_repository.portfolio.name
}

output "eks_cluster_name" {
  value = aws_eks_cluster.portfolio.name
}
