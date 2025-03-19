terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "jenkins-test-rg"
    storage_account_name = "tfstatestorage452523532"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
  subscription_id = "06750130-ff03-4088-81ae-2a02d52275ab"
}