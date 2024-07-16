# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of this project"
  type        = string
  default     = ""
}

variable "stage" {
  description = "deployment stage: [dev, int, prod, ...]"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "account id"
  type        = string
  default     = ""
}

variable "app_cache_arn" {
  description = "arn of the bucket to be used as a cache for optar"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "id of the vpc to be used by eks"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "list of subnet ids to be used by eks"
  type        = list(string)
  default     = []
}