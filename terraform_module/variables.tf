locals {
  name = "${var.env}-portfolio-${var.region}"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "env" {
  type        = string
  description = "The environment for this deployment (prd/stg)."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones."
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet cidrs."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet cidrs."
}

variable "instance_type" {
  type        = string
  description = "Intance type for eks "
  default     = "t2.small"
}
