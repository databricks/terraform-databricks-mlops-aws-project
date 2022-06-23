# MLOps AWS Project Module

In both of the specified staging and prod workspaces, this module:
* Creates and configures a service principal with appropriate permissions and entitlements to run CI/CD for a project. 
* Creates a workspace directory as a container for project-specific resources

The service principals are granted `CAN_MANAGE` permissions on the created workspace directories.

**_NOTE:_** 
1. This module is in preview so it is still experimental and subject to change. Feedback is welcome!
2. The [Databricks providers](https://registry.terraform.io/providers/databricks/databricks/latest/docs) that are passed into the module must be configured with workspace admin permissions.
3. The module assumes that the AWS Infrastructure Module has already been applied, namely that service principal groups with token usage permissions have been created with the name `"mlops-service-principals"`.
4. The service principal tokens are created with a default expiration of 100 days (8640000 seconds), and the module will need to be re-applied after this time to refresh the tokens.

## Usage
```hcl
provider "databricks" {
  alias = "staging"     # Authenticate using preferred method as described in Databricks provider
}

provider "databricks" {
  alias = "prod"     # Authenticate using preferred method as described in Databricks provider
}

module "mlops_aws_project" {
  source = "databricks/mlops-aws-project/databricks"
  providers = {
    databricks.staging = databricks.staging
    databricks.prod = databricks.prod
  }
  service_principal_name = "example-name"
  project_directory_path = "/dir-name"
}
```

### Usage example with Git credentials for service principal
This can be helpful for common use cases such as Git authorization for [Remote Git Jobs](https://docs.databricks.com/repos/jobs-remote-notebook.html).
```hcl
data "databricks_current_user" "staging_user" {
  provider = databricks.staging
}

data "databricks_current_user" "prod_user" {
  provider = databricks.prod
}

provider "databricks" {
  alias = "staging_sp"
  host  = data.databricks_current_user.staging_user.workspace_url
  token = module.mlops_aws_project.staging_service_principal_token
}

provider "databricks" {
  alias = "prod_sp"
  host  = data.databricks_current_user.prod_user.workspace_url
  token = module.mlops_aws_project.prod_service_principal_token
}

resource "databricks_git_credential" "staging_git" {
  provider              = databricks.staging_sp
  git_username          = var.git_username
  git_provider          = var.git_provider
  personal_access_token = var.git_token    # This should be configured with `repo` scope for Databricks Repos.
}

resource "databricks_git_credential" "prod_git" {
  provider              = databricks.prod_sp
  git_username          = var.git_username
  git_provider          = var.git_provider
  personal_access_token = var.git_token    # This should be configured with `repo` scope for Databricks Repos.
}
```

## Requirements
| Name | Version |
|------|---------|
|[terraform](https://registry.terraform.io/)|\>=1.1.6|
|[databricks](https://registry.terraform.io/providers/databricks/databricks/0.5.8)|\>=0.5.8|

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
|service_principal_name|The display name for the service principals.|string|N/A|yes|
|project_directory_path|Path/Name of Databricks workspace directory to be created for the project. NOTE: The parent directories in the path must already be created.|string|N/A|yes|

## Outputs
| Name | Description | Type | Sensitive |
|------|-------------|------|---------|
|project_directory_path|Path/Name of Databricks workspace directory created for the project.|string|no|
|staging_service_principal_application_id|Application ID of the created Databricks service principal in the staging workspace.|string|no|
|staging_service_principal_token|Sensitive personal access token (PAT) value of the created Databricks service principal in the staging workspace.|string|yes|
|prod_service_principal_application_id|Application ID of the created Databricks service principal in the prod workspace.|string|no|
|prod_service_principal_token|Sensitive personal access token (PAT) value of the created Databricks service principal in the prod workspace.|string|yes|

## Providers
| Name | Authentication | Use |
|------|-------------|----|
|databricks.staging|Provided by the user.|Create group, directory, and service principal module in the staging workspace.|
|databricks.prod|Provided by the user.|Create group, directory, and service principal module in the prod workspace.|

## Resources
| Name | Type |
|------|------|
|databricks_group.staging_sp_group|data source|
|databricks_group.prod_sp_group|data source|
|databricks_directory.staging_directory|resource|
|databricks_permissions.staging_directory_usage|resource|
|databricks_directory.prod_directory|resource|
|databricks_permissions.prod_directory_usage|resource|
|aws-service-principal.staging_sp|module|
|aws-service-principal.prod_sp|module|