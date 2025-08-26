terraform { required_version = ">= 1.5.0" }

locals {
  oidc_provider     = var.oidc_provider
  oidc_provider_arn = var.oidc_provider_arn
}

# cert-manager trust + policy (Route53 DNS-01)
data "aws_iam_policy_document" "cert_manager_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:cert-manager:cert-manager"]
    }
  }
}


data "aws_iam_policy_document" "cert_manager_policy" {
  statement {
    effect   = "Allow"
    actions  = ["route53:GetChange","route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    effect   = "Allow"
    actions  = ["route53:ListHostedZones","route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "cert_manager" {
  name               = "${var.name_prefix}-cert-manager"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_trust.json
  tags               = var.tags
}
resource "aws_iam_policy" "cert_manager" {
  name   = "${var.name_prefix}-cert-manager"
  policy = data.aws_iam_policy_document.cert_manager_policy.json
}
resource "aws_iam_role_policy_attachment" "cert_manager" {
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

# ExternalDNS trust + policy
data "aws_iam_policy_document" "external_dns_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals { 
        type = "Federated" 
        identifiers = [local.oidc_provider_arn] 
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-dns:external-dns"]
    }
  }
}
data "aws_iam_policy_document" "external_dns_policy" {
  statement {
    effect   = "Allow"
    actions  = ["route53:ChangeResourceRecordSets","route53:ListHostedZones","route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}
resource "aws_iam_role" "external_dns" {
  name               = "${var.name_prefix}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_trust.json
  tags               = var.tags
}
resource "aws_iam_policy" "external_dns" {
  name   = "${var.name_prefix}-external-dns"
  policy = data.aws_iam_policy_document.external_dns_policy.json
}
resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}


