# aurora

A Terraform module to create an Aurora cluster and instances.

## Example

```
module "database" {
  source  = "cloudboss/aurora/aws"
  version = "x.x.x"

  database = {
    manage_password = true
    name            = "application"
    username        = "bob"
  }
  kms_key_ids = {
    password = "alias/db-passwords"
    storage  = "alias/db-storage"
  }
  engine = {
    type    = "aurora-postgresql"
    version = "16.2"
  }
  name               = "application"
  security_group_ids = [var.security_group_id]
  serverless_v2 = {
    max_capacity = 4
    min_capacity = 0.5
  }
  skip_final_snapshot = true
  subnet_ids          = var.private_subnet_ids
  tags                = local.tags
}
```
