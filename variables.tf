# Copyright © 2024 Joseph Wright <joseph@cloudboss.co>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

variable "apply_immediately" {
  type        = bool
  description = "Whether or not to apply changes immediately."

  default = true
}

variable "backups" {
  type = object({
    retention_period = optional(number, null)
    preferred_window = optional(string, null)
  })
  description = "Configuration for backups."

  default = {}
}

variable "database" {
  type = object({
    manage_password = optional(bool, true)
    name            = string
    username        = string
  })
  description = "Configuration for the logical database."
}

variable "enable_http_endpoint" {
  type        = bool
  description = "Whether or not to enable the HTTP endpoint."

  default = false
}

variable "engine" {
  type = object({
    mode    = optional(string, "provisioned")
    type    = string
    version = string
  })
  description = "Configuration for the database engine."
}

variable "instance_class" {
  type        = string
  description = "The instance class. Not required if serverless v2 is enabled."

  default = null
}

variable "instances" {
  type        = number
  description = "The number of instances to create."

  default = 1
}

variable "kms_key_ids" {
  type = object({
    password = optional(string, null)
    storage  = string
  })
  description = "KMS key IDs for encryption of passwords and storage. The IDs may be in the form of aliases."
}

variable "monitoring" {
  type = object({
    interval = optional(number, 0)
    role_arn = optional(string, null)
  })
  description = "Configuration for monitoring."

  default = {}
}

variable "name" {
  type        = string
  description = "The name of the RDS cluster."
}

variable "network_type" {
  type        = string
  description = "The network type for the RDS cluster. Must be one of DUAL or IPV4."

  default = "IPV4"

  validation {
    condition     = contains(["DUAL", "IPV4"], var.network_type)
    error_message = "Invalid network type: must be DUAL or IPV4."
  }
}

variable "serverless_v2" {
  type = object({
    max_capacity = number
    min_capacity = number
  })
  description = "Configuration for serverless v2. Defining this will enable serverless v2."

  default = null
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Whether or not to skip the final snapshot when destroying."

  default = false
}

variable "security_group_ids" {
  type        = list(string)
  description = "IDs of security groups to attach to the RDS cluster."
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs of subnets in which to place the RDS cluster."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."

  default = {}
}
