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

locals {
  engine_mode     = var.serverless_v2 == null ? var.engine.mode : "provisioned"
  instance_class  = var.serverless_v2 == null ? var.instance_class : "db.serverless"
  master_password = one(random_password.master_password[*].result)
  master_password_kms_key_id = (
    var.database.manage_password ? var.kms_key_ids.password : null
  )
}

data "aws_kms_key" "password" {
  count = var.database.manage_password ? 0 : 1

  key_id = var.kms_key_ids.password
}

data "aws_kms_key" "storage" {
  key_id = var.kms_key_ids.storage
}

resource "random_password" "master_password" {
  count = var.database.manage_password ? 0 : 1

  length  = 16
  special = true
}

resource "aws_db_subnet_group" "it" {
  name       = var.name
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_rds_cluster" "it" {
  apply_immediately               = var.apply_immediately
  backup_retention_period         = var.backups.retention_period
  cluster_identifier              = var.name
  database_name                   = var.database.name
  db_cluster_parameter_group_name = one(aws_rds_cluster_parameter_group.it[*].name)
  db_subnet_group_name            = aws_db_subnet_group.it.name
  enable_http_endpoint            = var.enable_http_endpoint
  engine                          = var.engine.type
  engine_mode                     = local.engine_mode
  engine_version                  = var.engine.version
  kms_key_id                      = data.aws_kms_key.storage.arn
  manage_master_user_password     = var.database.manage_password
  master_user_secret_kms_key_id   = one(data.aws_kms_key.password[*].arn)
  master_username                 = var.database.username
  master_password                 = local.master_password
  preferred_backup_window         = var.backups.preferred_window
  skip_final_snapshot             = var.skip_final_snapshot
  storage_encrypted               = true
  tags                            = var.tags
  vpc_security_group_ids          = var.security_group_ids

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverless_v2 == null ? [] : [1]
    content {
      max_capacity = var.serverless_v2.max_capacity
      min_capacity = var.serverless_v2.min_capacity
    }
  }
}

resource "aws_rds_cluster_instance" "them" {
  count = var.instances

  cluster_identifier   = aws_rds_cluster.it.id
  db_subnet_group_name = aws_db_subnet_group.it.name
  engine               = aws_rds_cluster.it.engine
  engine_version       = aws_rds_cluster.it.engine_version
  identifier           = "${var.name}-${count.index + 1}"
  instance_class       = local.instance_class
  monitoring_interval  = var.monitoring.interval
  monitoring_role_arn  = var.monitoring.role_arn
}

resource "aws_rds_cluster_parameter_group" "it" {
  count = var.parameter_group == null ? 0 : 1

  description = var.name
  family      = var.parameter_group.family
  name        = var.name
  tags        = var.tags

  dynamic "parameter" {
    for_each = var.parameter_group.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}
