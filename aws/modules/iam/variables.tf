variable "cluster_name" {
  description = "EKS cluster name for IAM role binding"
  type        = string
}

variable "service_account_namespace" {
  description = "Namespace where the service account is deployed"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for IAM role and policy names"
  type        = string
  
}

variable "tags" { 
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}

}

variable "oidc_provider" {
  description = "The OIDC provider URL for the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
}
