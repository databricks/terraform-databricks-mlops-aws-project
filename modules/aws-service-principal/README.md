# AWS Service Principal Module

This module will create a Databricks Service Principal in an AWS workspace, outputting its application ID and personal access token (PAT).

**_NOTE:_** The [Databricks provider](https://registry.terraform.io/providers/databricks/databricks/latest/docs) that is passed into the module must be configured with workspace admin permissions to allow service principal creation.

## Usage
```hcl
provider "databricks" {} # Authenticate using preferred method as described in Databricks provider

module "aws_sp" {
  source = "databricks/aws-service-principal/databricks"
  providers = {
    databricks = databricks
  }
  display_name = "example-name"
  group_name   = "example-group"
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
|display_name|The desired display name for the service principal in Databricks.|string|N/A|yes|
|group_name|The Databricks group name that the service principal will belong to. NOTE: The main purpose of this group is to give the service principal token usage permissions, so the group should have token usage permissions.|string|N/A|yes|

## Outputs
| Name | Description | Type | Sensitive |
|------|-------------|------|---------|
|service_principal_application_id|Application ID of the created Databricks service principal.|string|no|
|service_principal_token|Sensitive personal access token (PAT) value of the created Databricks service principal. NOTE: The token is created with an expiration of 100 days (8640000 seconds) and the module will need to be re-applied after this time to refresh the token.|string|yes|

## Providers
| Name | Authentication | Use |
|------|-------------|----|
|databricks|Provided by the user.|Generate all workspace resources.|

## Resources
| Name | Type |
|------|------|
|databricks_service_principal.sp|resource|
|databricks_group.sp_group|data source|
|databricks_group_member.add_sp_to_group|resource|
|databricks_obo_token.token|resource|