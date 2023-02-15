data "databricks_group" "staging_sp_group" {
  provider     = databricks.staging
  display_name = var.service_principal_group_name
}

data "databricks_group" "prod_sp_group" {
  provider     = databricks.prod
  display_name = var.service_principal_group_name
}

module "staging_sp" {
  source = "./modules/aws-service-principal"
  providers = {
    databricks = databricks.staging
  }
  display_name = "staging-${var.service_principal_name}"
  group_name   = data.databricks_group.staging_sp_group.display_name
}

module "prod_sp" {
  source = "./modules/aws-service-principal"
  providers = {
    databricks = databricks.prod
  }
  display_name = "prod-${var.service_principal_name}"
  group_name   = data.databricks_group.prod_sp_group.display_name
}

resource "databricks_directory" "staging_directory" {
  provider = databricks.staging
  path     = "${var.project_directory_path}-staging"
}

resource "databricks_permissions" "staging_directory_usage" {
  provider       = databricks.staging
  directory_path = databricks_directory.staging_directory.path

  access_control {
    service_principal_name = module.staging_sp.service_principal_application_id
    permission_level       = "CAN_MANAGE"
  }
}

resource "databricks_directory" "prod_directory" {
  provider = databricks.prod
  path     = "${var.project_directory_path}-prod"
}

resource "databricks_permissions" "prod_directory_usage" {
  provider       = databricks.prod
  directory_path = databricks_directory.prod_directory.path

  access_control {
    service_principal_name = module.prod_sp.service_principal_application_id
    permission_level       = "CAN_MANAGE"
  }
}
