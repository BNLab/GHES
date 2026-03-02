terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-gov-rg"
    storage_account_name = "bnlabazuredevworktfstate"
    container_name       = "tfstate"
    key                  = "ghes/persistent.tfstate"
  }
}