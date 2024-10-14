## Table of Contents

- [dynamodb](#dynamodb)
- [variables](#variables)
- [provider](#useful-commands)
- [dev](#branch-naming-conventions)


### DynamodB 

This file contains dynamodb configuration where multiple dynamodb's are required. Each DB configuration can then be provided in dev.tfvar file with any variations. Otherwise it will pick default values from Variables file

### Variables 
This Variables files contains all variables required for DynamodB table as default. Any Variations provided in tfvars file will overwrite these default values

### Provider
Provider information is required since we are not using main.tf file as AWS Provider

### dev.tfvars
This primary file can be replicated for different Dev, Test, Staging and Production Environments. Further any variables defined here will overwrite default values. 

