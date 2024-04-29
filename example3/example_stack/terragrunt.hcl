inputs = {
    input_string = local.hello_world
    extra_input = "Hello Extra World"
}

locals {
    hello_world = format("%s %s", "Hello", "World")
}

include "template" {
    path = find_in_parent_folders("terragrunt_template.hcl")
}

remote_state {
  backend = "azurerm"
  config ={
    resource_group_name =  "example_rg"
    storage_account_name = "example_sa"
    container_name       = "example_container"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

terraform {
    source = "../example_module"
}