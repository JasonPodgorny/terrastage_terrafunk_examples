inputs = {
    input_string = local.hello_world
    extra_input = "Hello Extra World"
}

locals {
    hello_world = format("%s %s", "Hello", "World")
}

include {
    path = find_in_parent_folders("terragrunt_template.hcl")
}

terraform {
    source = "${path_relative_from_include()}/example_module"
}