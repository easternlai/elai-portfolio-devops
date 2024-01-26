data "tls_certificate" "portfoliio" {
  url = aws_eks_cluster.portfolio.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "portfolio" {
  url = aws_eks_cluster.portfolio.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [data.tls_certificate.portfoliio.certificates[0].sha1_fingerprint]
}
