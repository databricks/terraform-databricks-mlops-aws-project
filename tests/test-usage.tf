terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "0.5.8"
    }
  }
}

provider "databricks" {
  alias = "staging"
}

provider "databricks" {
  alias = "prod"
}

module "mlops_aws_project" {
  source = "../."
  providers = {
    databricks.staging = databricks.staging
    databricks.prod    = databricks.prod
  }
  service_principal_name = "example-name"
  project_directory_path = "/dir-name"
}
