Terraform requires IAM user credentials with the necessary privileges to perform the provisioning and deprovisioning of AWS resources.

This document will provide guidance on creating the following IAM resources for Terraform:

- terraform IAM user account
- IAM role for terraform user account

It is assumed you have an AWS account with a user account that has programmatic access and permissions to create IAM resources.

Note that the following code examples assumes a bash shell and the `$` denotes the beginning of a command line shell to help make a distinction between the entered command and the resulting output.  It should not be included when executing the command. 

TODO: Automate this

# Requirements

## Install the AWS CLI

[Install the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

Note: If you have the v1 installed, follow the guide to uninstall it and install the latest version.

## Configure your AWS CLI profile

Skip this step if you already have your AWS CLI configured.

The example below creates an AWS CLI profile named `myfirstspa`; adjust accordingly.     

```bash
$ aws configure --profile myfirstspa
AWS Access Key ID [None]: AKIXXXXXXXXXXXXXXXXO
AWS Secret Access Key [None]: dRxXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXSzd
Default region name [None]: us-east-1
Default output format [None]: json 

$ export AWS_PROFILE=myfirstspa
```

# Create Terraform IAM resources

The following examples create AWS IAM resources for Terraform.

## Create an IAM user account

Execute:
```bash
$ aws iam create-user --user-name terraform
```

Response:
```
{
    "User": {
        "Path": "/",
        "UserName": "terraform",
        "UserId": "AXXXXXXXXXXXXXXXXXXXU",
        "Arn": "arn:aws:iam::0XXXXXXXXXX0:user/terraform",
        "CreateDate": "2020-07-12T14:35:27Z"
    }
}
```

## Create an IAM role

### Create a local helper for role config as a json.

**`COPY`** the following code, **`PASTE`** it in the bash, **`REPLACE`** the `principal` AWS value with the user `arn` that you got previously when created the `terraform` IAM user.

```bash
$ cat << EOF > spa-iam-role-trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Principal": { 
            "AWS": "arn:aws:iam::0XXXXXXXXXX0:user/terraform"
        },
        "Action": "sts:AssumeRole"
    }
}
EOF
```

#### Create new role in the AWS:

Execute:
```bash
$ aws iam create-role --role-name terraformRole --assume-role-policy-document file://spa-iam-role-trust-policy.json
```

Response:
```bash
{
    "Role": {
        "Path": "/",
        "RoleName": "terraformRole",
        "RoleId": "BXXXXXXXXXXXXXXXXXXXV",
        "Arn": "arn:aws:iam::0XXXXXXXXXX0:role/terraformRole",
        "CreateDate": "2020-07-12T15:14:00+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::0XXXXXXXXXX0:user/terraform"
                },
                "Action": "sts:AssumeRole"
            }
        }
    }
}
```
    
## Attach Policies 

### Attach the `AdministratorAccess` policy to the `terraformRole` role.

Execute:
```bash
$ aws iam attach-role-policy --role-name terraformRole --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### Create and attach an IAM policy to use `cloud.jam3.net` domains

Create and attach an IAM policy to grant `sts:AssumeRole` for the `arn:aws:iam::152901669089:role/Jam3DevOpsDNSZoneAdminRole` role.

This cross-account role is used to access the `cloud.jam3.net` Route53 zone to seutp a custom CloudFront domain.

**`MAKE SURE`** the new terraform user has been added as `Trusted entities` in the main DevOps AWS account in the Jam3DevOpsDNSZoneAdminRole. Please contact Technical Architect or Technical Director on your project or email (`devops@jam3.com`).

Create a local helper for role config as a json. Run as is, no arn replacments are needed:

Execute:
```bash
$ cat << EOF > spa-iam-assume-role-policy.json
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Resource": "arn:aws:iam::152901669089:role/Jam3DevOpsDNSZoneAdminRole",
        "Action": "sts:AssumeRole"
    }
}
EOF
```

### Create new policy in the AWS:

Execute:
```bash
$ aws iam create-policy --policy-name assumeTerraformRolePolicy --policy-document file://spa-iam-assume-role-policy.json
```

Response:
```
{
    "Policy": {
        "PolicyName": "assumeTerraformRolePolicy",
        "PolicyId": "CXXXXXXXXXXXXXXXXXXXY",
        "Arn": "arn:aws:iam::0XXXXXXXXXX0:policy/assumeTerraformRolePolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2020-07-21T12:02:57+00:00",
        "UpdateDate": "2020-07-21T12:02:57+00:00"
    }
}
```

**`REPLACE`** the `0XXXXXXXXXX0` with the arn value of the `assumeTerraformRolePolicy` policy you just created and execute:
```bash
$ aws iam attach-user-policy --user-name terraform --policy-arn arn:aws:iam::0XXXXXXXXXX0:policy/assumeTerraformRolePolicy
```

## Obtain API access credentials for Terraform AWS IAM user

Make note of the `AccessKeyId` and `SecretAccessKey` values from the resulting output. **The SecretAccessKey is shown only once!**\
These will be needed when [setting up Terraform Cloud](terraform-cloud-workspace.md).

Execute:
```bash
$ aws iam create-access-key --user-name terraform 
```

Response:
```
{
    "AccessKey": {
        "UserName": "terraform",
        "AccessKeyId": "AKIXXXXXXXXXXXXXXLND",
        "Status": "Active",
        "SecretAccessKey": "e1mXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXPhX",
        "CreateDate": "2020-07-12T15:21:26+00:00"
    }
}
```
