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