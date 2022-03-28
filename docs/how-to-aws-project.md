An AWS account is required to provision a Single Page Application with the Terraform configuration found in this repository.

This document assumes you have:

- [Installed the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) 
- Possess an **IAM user account with programmatic access** to an AWS account and have authority to manage IAM 

Contact Technical Architect or Technical Director on your project to obtain an IAM account for AWS.  

The above items are required in order to setup the necessary IAM user and role, that Terraform uses when executing resource provisioning, for details refer to the [Setup AWS Credentials for Terraform](./aws-terraform-credentials.md) document.
