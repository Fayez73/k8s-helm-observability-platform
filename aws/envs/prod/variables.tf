variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
}

variable "cluster_name" {
  type        = string
}

variable "cluster_version" {
  type        = string
}

variable "node_instance_types" {
  type        = list(string)
}

variable "node_desired_size" {
  type        = number
}

variable "node_min_size" {
  type        = number
}

variable "node_max_size" {
  type        = number
}

variable "tags" {
  type        = map(string)
  default     = {}
}
