# Example 2 - Terragrunt Templates

In this second example, we are adding a template into our terragrunt configuration.   The purpose of templates is to create a set of code that will be reused across your terragrunt stacks which keeps you from having to repeat that same code in each of them.  Like the previous example, our terragrunt template is kept intentionally simple just to demonstrate the concepts and how it is used.

## example_template

The example module is very basic, it is only one file called terragrunt_template.hcl and it contains only two blocks.   The first is the locals block.    In this there is just a simple string argument with the test "Hello Template World".    In addition we have an inputs block that uses this local variable twice.   The first time is a string called input_string, which is the same name we have used for one of our variables in the stack configuration file.    We use it again as a variable with the name extra_string_template.

```
inputs = {
    input_string = local.hello_world_template
    extra_string_template = local.hello_world_template
}

locals {
    hello_world_template = "Hello Template World"
}
```



 

## example_stack changes

In the example stack configuration file we add one configuration block which calls this template.    It uses a terragrunt function called *find_in_parent_folders* along with the file name of the template that is being called.   A detailed explanation on this function can be found in the following link, but at a high level this function just searches up the directory tree from your current location, finds the file that is specified, and gives a complete path to the file:  https://terragrunt.gruntwork.io/docs/reference/built-in-functions/#find_in_parent_folders

```
include "template" {
    path = find_in_parent_folders("terragrunt_template.hcl")
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

The json output above has only a few minor changes from what we saw in example 1.    Specifically the inputs section now has a new input called extra_string_template.    This includes the text string "Hello World Template" like we specified for that input in the terragrunt template file.    The variable of input_string is still "Hello World".    We included this variable in the template, but it stayed the same.    This is because the order of precedence for these variables - while the template has a variable with this name the copy of this that is local to the stack takes priority and is the one that ends up being used.

Also of note, we only see the locals section from the stack configuration, the locals that are included in the template are local only to that template and aren't directly accessible inside of the configuration file.



Another use for the terrafunk utility is highlighted below.    As we didn't see the result of the *find_in_parent_folders* in the above output we can use the terrafunk utility with the -expression flag to demonstrate what exactly this function is doing.    We see below that it searched up the directory tree and found the terragrunt template in the base configuration folder.

```
example_stack> ..\..\bin\terrafunk_windows_amd64_v0.55.10.exe -expression 'find_in_parent_folders(\"terragrunt_template.hcl\")'
"C:/Temp/terrastage_examples/example2/terragrunt_template.hcl"
```



## terrastage

Next we will run the terrastage utility against this configuration.   There are a few switches that are available to influence its behavior, we again use all of the default options.

```
example_stack> ..\..\bin\terrastage_windows_amd64_v0.55.20.exe

time=2024-04-29T13:53:00-04:00 level=info msg=Downloading Terraform configurations from file://C:/Temp/terrastage_examples/example2/example_module into C:/Temp/terrastage_examples/example2/example_stack/.terrastage

time=2024-04-29T13:53:00-04:00 level=info msg=Generating TFVARS file test.auto.tfvars.json in working dir C:/Temp/terrastage_examples/example2/example_stack/.terrastage

time=2024-04-29T13:53:00-04:00 level=info msg=Variables passed to terraform are located in "C:\Temp\terrastage_examples\example2\example_stack\.terrastage\test.auto.tfvars.json"
time=2024-04-29T13:53:00-04:00 level=info msg=Run this command to replicate how terraform was invoked:

time=2024-04-29T13:53:00-04:00 level=info msg=  terraform -chdir="C:/Temp/terrastage_examples/example2/example_stack/.terrastage"  -var-file="C:\Temp\terrastage_examples\example2\example_stack\.terrastage\test.auto.tfvars.json"
```



We can see from the above logs once again, the same actions happened as we saw in the previous example and our .terrastage folder looks like below:

![image-20240405130914448](.\readme_images\image-20240405130914448.png)

##### test.auto.tfvars.json

One thing to note is that the contents of these files are exactly the same as we saw in the previous example.   We did have an extra input when we looked at the terragrunt configuration, but since our module does not require this input it was discarded like we saw with extra inputs in our previous example.

```
{
  "input_string": "Hello World"
}
```



## terraform plan

All of the above files have once again given us a complete terraform stack, including all of the necessary inputs.    We can simply change to the .terrastage directory and run a terraform plan without any additional options.     The results should be familiar as they are the exact same results we got both times we ran this command in the previous example.

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

## Summary

In this example we saw an extremely simple terragrunt template, how to find and use this within our configuration, and got a little insight into how the order or precedence works for the variables that are found here.    In the following examples we'll start to add in a bit more functionality, both in the example stack and into our terragrunt template to continue illustrating some more terragrunt functions, how they work, and how to  use our utilities to look more into what is happening when code is added into each of these. 