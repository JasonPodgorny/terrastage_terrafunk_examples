# Terragrunt

Terragrunt is a popular wrapper utility for Terraform that provides extra tools for:

- Keeping your configurations DRY (Don't Repeat Yourself)
- Working with multiple Terraform modules
- Managing remote state
- And More

## Terrastage

I've created a helper utility called Terrastage that leverage Terragrunt but distills it down to only functionality that is necessary to use it as a pre-processor to create native terraform stacks, which can then use Terraform itself using a wide array of execution mechanisms such as:

- Terraform CLI itself 
- Azure Devops Pipeline Terraform Tasks
- Terraform Cloud
- Other TACOS Tools such as Spacelift / Scalr / Atlantis 

## Terrafunk

Another helper utility was created called Terrafunk.   This also leverages Terragrunt but distills things even further, allowing you to execute Terragrunt and Terraform functions from the command line.    This is excellent to testing functions and their results very quickly but also allows you to quickly inspect Terragrunt/Terrastage configurations.    This is helpful in really diving into what happens under the hood of Terragrunt but also helps to troubleshoot what is going on as configurations become more complex, write quick unit tests against Terragrunt configuration files and templates, etc.

## Examples Overview

The purpose of these examples is to provide a quick introduction to demystify these utilities and Terragrunt itself a little bit.    It is not intended as a full set of documentation but more as a quick illustration of how these tools all operate against the most basic of Terragrunt configurations and templates leveraging an extremely simply Terraform module.

A full set of Terragrunt documentation can be found here:  https://terragrunt.gruntwork.io/docs/

In addition, the book "Terraform Up And Running" was written by the creator of Terragrunt and there is a chapter in that book that covers the utility along with a lot of information that demonstrates why it is useful and the concepts that went into it.    I highly recommend reading this book.

More information on Terrastage can be found here:  https://github.com/JasonPodgorny/terrastage

More information on Terrafunk can be found here:  https://github.com/JasonPodgorny/terrafunk

## Examples README.md's

 Each example folder contains a README, continue to those.