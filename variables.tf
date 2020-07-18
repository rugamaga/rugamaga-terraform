locals {
  workspaces = {
    default = "${local.dev}"
    dev     = "${local.dev}"
    prd     = "${local.prd}"
  }

  workspace = "${local.workspaces[terraform.workspace]}"

  tags = {
    Terraform   = "true"
    Environment = "${terraform.workspace}"
  }
}
