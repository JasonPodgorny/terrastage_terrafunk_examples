inputs = {
    input_string = local.hello_world_template
    extra_string_template = local.hello_world_template
}

locals {
    hello_world_template = "Hello Template World"
}