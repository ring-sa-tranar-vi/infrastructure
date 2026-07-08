terraform {
  backend "gcs" {
    bucket = var.terraform_state_bucket
    prefix = "${var.terraform_state_prefix}/staging"
  }
}

module "app" {
  source      = "../modules/app"
  environment = "staging"
}