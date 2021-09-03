# BespinGlobal Terraform Training 
> author: Changsuk Choi

> company: BespinGlobal

## Benefits of Terragrunt
  - Don’t Repeat Yourself (DRY): Easy keeping code DRY about remote state configuration and common app-level variables.
  - Skip init command: Auto-Init is a feature of Terragrunt that makes it so that terragrunt init does not need to be called explicitly before other terragrunt commands.
  - Temporary source: Using --terragrunt-source command download Terraform configurations from the specified source into a temporary folder, and run Terraform in that temporary folder.

## Required Version
 - Terraform: v1.0.5
 - Terragrunt: v0.31.8
 - AWS Provider: v3.56.0
