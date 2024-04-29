# Example 3 - Remote State

In this third example, we are adding a remote state block into our terragrunt configuration.   One of the shortcomings of native terraform is that it does not allow us to use variables, expressions, or functions in the remote state configuration which can create some difficulties in managing your remote states when modules are being used.   To help alleviate this, terragrunt provides the remote_state block which does allow us to use these code elements when managing these blocks.   

More information on this use case can be found in the terragrunt documentation below:

https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#remote_state

https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/



In our next few examples we will show some examples of the remote_state block.   In this example we will create a basic block and then see the results of this in terms of our helper utilities.    In the next two examples we will then move this configuration into the terragrunt template and then use another of terragrunt's blocks to generate a backend configuration that allows these to be leveraged by terraform. 

## remote_state block

In this example the following block was added to the terragrunt stack configuration file.   It's very basic - for now we will simply specify an example resource group, storage account, and container statically but use another terragrunt function *path_relative_to_include* to show how we can specify the key for the remote state block, which allows us to organize our remote state files to match the folder structure that we have created for our stacks.

```
remote_state {
  backend = "azurerm"
  config ={
    resource_group_name =  "example_rg"
    storage_account_name = "example_sa"
    container_name       = "example_container"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}
```



## terrafunk

We will again look at what happens when we use our utilities against this terragrunt configuration.    First we use terrafunk,  

```
example_stack> ..\..\bin\terrafunk_windows_amd64_v0.55.10.exe
{
  "dependencies": null,
  "download_dir": "",
  "generate": {},
  "iam_assume_role_duration": null,
  "iam_assume_role_session_name": "",
  "iam_role": "",
  "inputs": {
    "extra_input": "Hello Extra World",
    "extra_string_template": "Hello Template World",
    "input_string": "Hello World"
  },
  "locals": {
    "hello_world": "Hello World"
  },
  "remote_state": {
    "backend": "azurerm",
    "config": {
      "container_name": "example_container",
      "key": "example_stack/terraform.tfstate",
      "resource_group_name": "example_rg",
      "storage_account_name": "example_sa"
    },
    "disable_dependency_optimization": false,
    "disable_init": false,
    "generate": null
  },
  "retry_max_attempts": null,
  "retry_sleep_interval_sec": null,
  "retryable_errors": null,
  "skip": false,
  "terraform": {
    "after_hook": {},
    "before_hook": {},
    "error_hook": {},
    "extra_arguments": {},
    "include_in_copy": null,
    "source": "../example_module"
  },
  "terraform_binary": "",
  "terraform_version_constraint": "",
  "terragrunt_version_constraint": ""
}
```

The json output above now has an additional block called remote state.    The contents should mostly be as expected, it used the settings that we specified using static text directly.   For the key, it populated the key with our path relative to the terragrunt template that we included in the configuration.   This makes it easy to align these remote states to our folder structure relative to the templates that we are including.



## terrastage

Next we will run the terrastage utility against this configuration.   There are a few switches that are available to influence its behavior, we again use all of the default options.

```
example_stack> ..\..\bin\terrastage_windows_amd64_v0.55.20.exe

time=2024-04-29T15:30:36-04:00 level=info msg=Downloading Terraform configurations from file://C:/Temp/terrastage_examples/example3/example_module into C:/Temp/terrastage_examples/example3/example_stack/.terrastage

time=2024-04-29T15:30:36-04:00 level=error msg=Check Teraform Code Had The Following Errors: Found remote_state settings in C:\Temp\terrastage_examples\example3\example_stack\terragrunt.hcl but no backend block in the Terraform code in C:/Temp/terrastage_examples/example3/example_stack/.terrastage. You must define a backend block (it can be empty!) in your Terraform code or your remote state settings will have no effect! It should look something like this:

terraform {
  backend "azurerm" {}
}


time=2024-04-29T15:30:36-04:00 level=info msg=Generating backend config file backend.config in working dir C:/Temp/terrastage_examples/example3/example_stack/.terrastage

time=2024-04-29T15:30:36-04:00 level=info msg=Generating TFVARS file test.auto.tfvars.json in working dir C:/Temp/terrastage_examples/example3/example_stack/.terrastage

time=2024-04-29T15:30:36-04:00 level=info msg=Variables passed to terraform are located in "C:\Temp\terrastage_examples\example3\example_stack\.terrastage\test.auto.tfvars.json"

time=2024-04-29T15:30:36-04:00 level=info msg=Run this command to replicate how terraform was invoked:

time=2024-04-29T15:30:36-04:00 level=info msg=  terraform -chdir="C:/Temp/terrastage_examples/example3/example_stack/.terrastage"  -var-file="C:\Temp\terrastage_examples\example3\example_stack\.terrastage\test.auto.tfvars.json"
```



We can see from the above logs once again, the same actions happened as we saw in the previous example with the exception that it found our remote state settings.   Our terrastage folder now looks as follows:

![image-20240429153407729](.\readme_images\image-20240429153407729.png)

##### backend.config

One thing to note is that the contents of these files are exactly the same as we saw in the previous example with the exception that there is now a file called backend.config.   The contents of this file contain the variables that we saw in the previous terrafunk outputs.   

```
resource_group_name="example_rg"
storage_account_name="example_sa"
container_name="example_container"
key="example_stack/terraform.tfstate"
```

##### backend block warning

One thing to also note from the terrastage output above is that it gives a warning and lets us know that this backend.config file will not actually be used.   In order for this to actually be used we need a backend configuration block in our module, which our current module doesn't have.    In example 5 we will take a look at how this file can be generated programatically to deal with this error but for now we have a backend.config file with variables we generated programmatically and can be used to manage our remote state when that terraform configuration is created in this future example.

## Summary

In this example we saw a simple remote state block and how we can use this to generate backend configuration files programatically.