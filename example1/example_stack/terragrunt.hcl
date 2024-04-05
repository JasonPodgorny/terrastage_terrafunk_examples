inputs = {
    input_string = local.hello_world
    extra_input = "Hello Extra World"
}

locals {
    hello_world = format("%s %s", "Hello", "World")
}

terraform {
    source = "../example_module"
}