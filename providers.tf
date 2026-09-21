###############################################################################
# providers.tf — Landing Zone
#
# Declares the required Terraform version and provider versions.
# Authentication is supplied entirely via environment variables set by
# running .\set-auth.ps1 before any Terraform command:
#
#   ARM_CLIENT_ID        — Service-principal application (client) ID
#   ARM_CLIENT_SECRET    — Service-principal client secret
#   ARM_TENANT_ID        — Azure AD tenant ID
#   ARM_SUBSCRIPTION_ID  — Target Azure subscription ID
#
# No credentials are hardcoded here.
###############################################################################

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  # subscription_id, client_id, client_secret, and tenant_id are all resolved
  # automatically from the ARM_* environment variables loaded by set-auth.ps1.
  # No values need to be set explicitly here.

  features {}
}
