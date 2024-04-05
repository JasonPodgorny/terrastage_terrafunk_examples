inputs = {
    input_string = local.hello_world_template
    extra_string_template = local.hello_world_template

    module_path = path_relative_to_include()
}

locals {
    hello_world_template = "Hello Template World"
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

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  backend "azurerm" {
  }
}
EOF
}
