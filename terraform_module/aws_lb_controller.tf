provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.portfolio.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.portfolio.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.portfolio.name]
      command     = "aws"
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.portfolio.name
  }

  set {
    name  = "vpcId"
    value = aws_vpc.portfolio.id
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.ingress-role.arn
  }
}

