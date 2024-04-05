# Example 1 - Basic Terragrunt Configuration

The first example has two folders.   The first folder is called example_module and this is a very basic Terraform module.    This same module will be used throughout the course of these examples as they are intended to illustrate the Terragrunt based utilities and how they function.    

The second folder in this example is called example_stack.   This is a very basic Terragrunt configuration.   We will expand on this configuration throughout the course of these examples to illustrate more of what is available in a Terragrunt configuration and how the utilities behave as more pieces are added.

*We will not cover a full set of what is available in a Terragrunt configuration, the Terragrunt and Terraform documentation already provide excellent resources on this.*





## example_module

The example module is entirely basic, it is only one file called main.tf.   This file consists simply of a single input variable of string along with an output that uses this string.   

```
variable "input_string" {
  description = "Input String"
  type        = string
  default     = null
}

output "output_string" {
    value = var.input_string
}
```

 A terraform plan against this module using terraform itself, and specifying 'Hello World' as the input_string from the command line looks like this:

```
example_module> terraform plan -var "input_string=Hello World"

Changes to Outputs:
  + output_string = "Hello World"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```





## example_stack

![image-20240405122740878](.\readme_images\image-20240405122740878.png)



In the example stack folder we have two files.    The first is a json file called json_world.json which contains the following data.



##### json_world.json

```
{
    "json_world": "Hello JSON World"
}
```



The second file is called terragrunt.hcl - this is the standard name that is used for a terragrunt configuration file.    This file contains the following data:



##### terragrunt.hcl

```
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
```

 

One of the first things you should notice, this file is written in HCL, which is the native configuration syntax that terraform itself uses.    It uses many of the same configuration blocks - this example contains a locals block just like native terraform itself does and all logic that is contained in this is interpreted locally to this configuration file just like what happens in native terraform.    We are using the format function here to create a string, which is the exact same function that is available in terraform.   Because terragrunt is a wrapper, all functions that are available in terraform itself are available to be used within these files.     Let's look at each block a little closer.

### locals configuration block

As mentioned above this block behaves just like it does in actual terraform configuration files.    Here we are using the format function to create a string of "Hello World".    More details on this can be found in the Terragrunt documentation here:  https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#locals

### terraform configuration block

The `terraform` block is used to configure how Terragrunt will interact with Terraform.   You can specify command line arguments that will be used to pass to terraform.   The source statement used here tells Terragrunt where to get the Terraform module that will be used as part of this stack.   It uses the Terraform go-getter underneath the hood so any source statement you would use in a terraform configuration module call can be used here using the same syntax as outlines in the Terraform documentation.    

In our example here we are telling it to find the source code for the module in the example_module folder that is contained in this example.

More information on the terraform configuration block can be found here:  https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#terraform

### inputs configuration block

The inputs configuration block is a map of input variables that will be fed to the module that is called in the terraform configuration block above.

In our example we have specified two inputs.    The first is called input_string, which is the same name of the input variable we have specified in our module.    It uses the variable that was generated in the locals block for its string, showing how values from locals can be used in these inputs.   The second is an called extra_input.    Our module does not call for this input, and we have included this as a demonstration of how terragrunt / terrastage behave when an input variable that isn't needed is contained in the configuration.



## terrafunk

Now let's take a look at what happens when we use our utilities against this terragrunt configuration.    The first utility we will demonstrate is terrafunk.   This is designed to allow you to execute terragrunt and terraform commands from the command line.    Without any options it uses the read_terragrunt_config() function which will generate the end state configuration from our terragrunt configuration above:

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
    "input_string": "Hello World"
  },
  "locals": {
    "hello_world": "Hello World"
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



The json output above shows all of the options that terragrunt generates using the above configuration.   We haven't used most of these blocks so they are currently empty strings or null but for the blocks we have used we can see what happens after the functions in question have been run.     There is a locals section, this shows us the string after it has been run through the format function we used in the configuration.    We can see the inputs sections, and the input_string variable is now using the value that was generated in locals.    We can also see in the terraform section that it is using the example_module folder as we specified in the configuration.      

It's all pretty straight forward since our example is very basic, but this utility starts to become very valuable as use more of the configuration elements that are available and our logic starts to become a little more complex



## terrastage

Next we will run the terrastage utility against this configuration.   There are a few switches that are available to influence its behavior, to start with we will just go ahead and use all of the default options.

```
example_stack> ..\..\bin\terrastage_windows_amd64_v0.55.20.exe

time=2024-04-05T13:04:40-04:00 level=info msg=Downloading Terraform configurations from file://C:/Temp/terrastage_examples/example1/example_module into C:/Temp/terrastage_examples/example1/example_stack/.terrastage

time=2024-04-05T13:04:40-04:00 level=info msg=Generating TFVARS file test.auto.tfvars.json in working dir C:/Temp/terrastage_examples/example1/example_stack/.terrastage

time=2024-04-05T13:04:40-04:00 level=info msg=Variables passed to terraform are located in "C:\Temp\terrastage_examples\example1\example_stack\.terrastage\test.auto.tfvars.json"

time=2024-04-05T13:04:40-04:00 level=info msg=Run this command to replicate how terraform was invoked:

time=2024-04-05T13:04:40-04:00 level=info msg=  terraform -chdir="C:/Temp/terrastage_examples/example1/example_stack/.terrastage"  -var-file="C:\Temp\terrastage_examples\example1\example_stack\.terrastage\test.auto.tfvars.json"
```



We can see from the above logs, the following actions happened once we executed this from the example_stack folder:

- It created a folder called .terrastage in our example stack folder
- The example module folder was copied into .terrastage
- It generated a terraform variables file called test.auto.tfvars.json in .terrastage

One thing that the logs did not highlight is that is also copied all files from the example_stack folder into the .terrastage folder as well.    After all of these steps have been completed, the .terrastage folder looks like this:

![image-20240405130914448](.\readme_images\image-20240405130914448.png)

All of the .terragrunt files were created by terragrunt/terrastage.   In addition we have the following files:

- json_world.json - This file was copied from the example_stack folder
- main.tf - This file was copied from the example_module folder
- terragrunt.hcl - This file was copied from the example_stack folder
- test.auto.tfvars.json - This file was generated by terragrunt/terrastage

##### test.auto.tfvars.json

Looking at the actual contents of the tfvars file we see the following:

```
{
  "input_string": "Hello World"
}
```



## terraform plan

All of the above files have now given us a complete terraform stack, including all of the necessary inputs.    We can simply change to the .terrastage directory and run a terraform plan without any additional options.     The results should be familiar as they are the exact same results we got when we ran a terraform plan from the example_module folder, while specifying the input from the tfvars file on the command line.

```
.terrastage> terraform plan

Changes to Outputs:
  + output_string = "Hello World"

You can apply this plan to save these new output values to the Terraform state, without changing any real
infrastructure.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if
you run "terraform apply" now.
```



## Where Did extra_input Go?!

One thing you might have noticed above, our configuration included an input variable called "extra_input".    We saw this variable in our terrafunk results, but it wasn't in the tfvars file that got generated.     To see what's happening here, we will go ahead and use the -debug option for terrastage.   This gives us quite a bit more information in the logs, which can be very useful in determining what is happening under the hood of terragrunt/terrastage and also allows us to troubleshoot more deeply when things don't go as we might have expected.

From the below logs we should notice the following entry:   *time=2024-04-05T13:18:55-04:00 level=debug msg=WARN: The variable extra_input was omitted because it is not defined in the terraform module.*

Terragrunt / terrastage actually look at the inputs that the module itself is asking for, and they don't include anything from the inputs section that isn't required!    This is a neat little part of the functionality that allows us to avoid some warnings that terraform would have normally given us for this. 

```
..\..\bin\terrastage_windows_amd64_v0.55.20.exe -debug

time=2024-04-05T13:18:55-04:00 level=info msg=Workdir: C:\Temp\terrastage_examples\example1\example_stack\

time=2024-04-05T13:18:55-04:00 level=info msg=Stage Dir: C:\Temp\terrastage_examples\example1\example_stack\.terrastage\

time=2024-04-05T13:18:55-04:00 level=info msg=Stage Subdir Variable: module_path

time=2024-04-05T13:18:55-04:00 level=debug msg=Reading Terragrunt config file at C:\Temp\terrastage_examples\example1\example_stack\terragrunt.hcl

time=2024-04-05T13:18:55-04:00 level=debug msg=Found locals block: evaluating the expressions.

time=2024-04-05T13:18:55-04:00 level=debug msg=Evaluated 1 locals (remaining 0): hello_world

time=2024-04-05T13:18:55-04:00 level=debug msg=Found locals block: evaluating the expressions.

time=2024-04-05T13:18:55-04:00 level=debug msg=Evaluated 1 locals (remaining 0): hello_world

time=2024-04-05T13:18:55-04:00 level=info msg=Stage Subdir From Variable:

time=2024-04-05T13:18:55-04:00 level=debug msg=unknown files in C:/Temp/terrastage_examples/example1/example_stack/.terrastage are up to date. Will not download again.

time=2024-04-05T13:18:55-04:00 level=debug msg=Copying files from C:\Temp\terrastage_examples\example1\example_stack\ into C:/Temp/terrastage_examples/example1/example_stack/.terrastage

time=2024-04-05T13:18:55-04:00 level=debug msg=Setting working directory to C:/Temp/terrastage_examples/example1/example_stack/.terrastage

time=2024-04-05T13:18:55-04:00 level=info msg=Generating TFVARS file test.auto.tfvars.json in working dir C:/Temp/terrastage_examples/example1/example_stack/.terrastage

time=2024-04-05T13:18:55-04:00 level=debug msg=The following variables were detected in the terraform module:

time=2024-04-05T13:18:55-04:00 level=debug msg=[input_string]

time=2024-04-05T13:18:55-04:00 level=debug msg=WARN: The variable extra_input was omitted because it is not defined in the terraform module.

time=2024-04-05T13:18:55-04:00 level=info msg=Variables passed to terraform are located in "C:\Temp\terrastage_examples\example1\example_stack\.terrastage\test.auto.tfvars.json"

time=2024-04-05T13:18:55-04:00 level=info msg=Run this command to replicate how terraform was invoked:

time=2024-04-05T13:18:55-04:00 level=info msg=  terraform -chdir="C:/Temp/terrastage_examples/example1/example_stack/.terrastage"  -var-file="C:\Temp\terrastage_examples\example1\example_stack\.terrastage\test.auto.tfvars.json"
```



## What's The Point Of json_world.json

You might be asking, what is the point of the json_world.json file in this example?    It's not actually used for anything by the module, it was simply included here to demonstrate the fact that terragrunt / terrastage copy the entire contents of your stack folder into the location where the module and files are all staged.     This is extremely useful because we can include input files into our stack that the terraform module can then read in, which offers another way to get configuration / variables into our module.    

json, yaml, and csv files tend to be a lot easier to modify programatically than hcl files and this will be useful to us in the future.