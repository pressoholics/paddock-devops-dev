# Preparing Workspaces in Terraform Cloud

Terraform Cloud is a hosted solution that helps teams use Terraform together. It manages Terraform runs in a consistent and reliable environment, and includes easy access to shared state and secret data, access controls for approving changes to infrastructure, a private registry for sharing Terraform modules, detailed policy controls for governing the contents of Terraform configurations, and more.

This document will outline steps to create workspaces for a new project.

TODO: Automate this

## Login to Terraform Cloud

Login to [Terraform Cloud](https://app.terraform.io/) and switch to the `jam3` organization.\
If you do not have access to the `jam3` Terraform Cloud organization, please contact Technical Architect or Technical Director on your project or email (`devops@jam3.com`).

## Create a Terraform workspace

Begin by [creating a new workspace](https://app.terraform.io/app/jam3/workspaces/new).

Since we would like Terraform Cloud to automatically prepare and execute plans with each Terraform configuration change, we must associate the workspace with a VCS provider.

Select the `GitHub` VCS provider and choose the appropriate repository that holds the Terraform configuration associated with the workspace.

Choose a workspace name. Note that if mutiple workspaces are to be created for each stage of application development, it is recommended that the workspace should have a common [workspace](https://www.terraform.io/docs/backends/types/remote.html#workspaces) name prefix.

## Configure the Terraform workspace

Associate the workspace with a VCS branch. From the created workspace, go to `Settings > Version Control`, and change the VCS branch to match the intended environment the workspace will support.

From the created workspace, go to `Settings > General`, and adjust the following settings as needed:

- Execution mode. This should be set to `Remote` to have Terraform Cloud automatically prepare plans for Terraform configuration changes.
- Terraform Version. You **MUST** use the 1.0.11 version.
- Apply method. Determines whether plans are automatically applied or whether manual confirmation is needed. For workspaces supporting non-production environments, this can be set to `Auto Apply`.
- Terraform Working Directory. Respository subdirectory where the Terraform configuration files are located.

Set workspace variables for AWS IAM tokens. From the created workspace, go to `Settings > Variables`.
Terraform Cloud will automatically use Terraform variables found in committed `*.auto.tfvars` files. However, senstive information that should not be commited to version control, such as API tokens, should be manually defined here.

Create the following Terraform workspace environment variables, marked as `Sensitive`, for the programmatic API credentials of the AWS IAM user that Terraform should use during plan execution.

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

# API Examples

The following API calls require an authorization token. Please refer to the [Terraform API Tokens](https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html) documentation for setting up an API token.

Note that the following code examples assumes a bash shell and the `$` denotes the beginning of a command line shell to help make a distinction between the entered command and the resulting output. It should not be included when executing the command.

## Get VCS OAuth token ID

The OAuth token is needed during workspace creation.

```
$ curl -s \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organizations/jam3/oauth-clients \
  | jq '{ "oauth-token-id": .data[0].relationships."oauth-tokens".data[0].id }'

{
  "oauth-token-id": "ot-NpC22nBHwxf8nUbx"
}
```

## Create a Workspace

Refer to the [Terraform API Workspace](https://www.terraform.io/docs/cloud/api/workspaces.html) documentation for a detailed description of supported attributes.

In the example below, the `vcs-repo.identifier` refers to the repository name and should be adjusted accordingly. Additionally, it may be desired to set `allow-destory-plan` and `auto-apply` to false for production environments.

The `vcs-repo.oath-token-id` value is obtained from the oauth-clients API call shown above.

Define JSON payload for workspace creation details

```
$ cat << EOF > ~/tf_workspace_payload.json
{
  "data": {
    "attributes": {
      "name": "myfirstspa-develop",
      "working-directory": "",
      "allow-destroy-plan": true,
      "auto-apply": true,
      "operations": true,
      "terraform-version": "1.0.11",
      "vcs-repo": {
        "identifier": "Jam3/devops-aws-spa",
        "oauth-token-id": "ot-NpC22nBHwxf8nUbx",
        "branch": "develop",
        "default-branch": true
      }
    },
    "type": "workspaces"
  }
}
EOF
```

Make workspace creation call

```
$ curl -s \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -X POST \
  --data @~/tf_workspace_payload.json \
  https://app.terraform.io/api/v2/organizations/jam3/workspaces \
  | jq '{ "workspace-id": .data.id }'

{
  "workspace-id": "ws-UTRy8ynRv88ztF1T"
}
```

## Set Workspace Variables

Set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` variables for the IAM user that Terraform Cloud will use when provisioning AWS resources. Refer to [AWS Credentials for Terraform](./aws-terraform-credentials.md) for details on creating an IAM user for Terraform.

Be careful when writing AWS API credentials to files. Clean up afterwards or adjust the process accordingly.

The workspace ID value in the API URL is obtained from the workspace creation API call shown above.

Create AWS_ACCESS_KEY_ID environment variable

```
$ cat << EOF > ~/tf_aws_access_key_payload.json
{
  "data": {
    "type":"vars",
    "attributes": {
      "key":"AWS_ACCESS_KEY_ID",
      "value":"AKIXXXXXXXXXXXXXXLND",
      "description":"AWS Access Key ID",
      "category":"env",
      "hcl":false,
      "sensitive":true
    }
  }
}
EOF

$ curl -s \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -X POST \
  --data @~/tf_aws_access_key_payload.json \
  https://app.terraform.io/api/v2/workspaces/ws-UTRy8ynRv88ztF1T/vars \
  | jq '.'

{
  ... snip ...
}
```

Create AWS_SECRET_ACCESS_KEY environment variable

```
$ cat << EOF > ~/tf_aws_secret_access_key_payload.json
{
  "data": {
    "type":"vars",
    "attributes": {
      "key":"AWS_SECRET_ACCESS_KEY",
      "value":"e1mXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXPhX",
      "description":"AWS Secret Access Key",
      "category":"env",
      "hcl":false,
      "sensitive":true
    }
  }
}
EOF

$ curl -s \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -X POST \
  --data @~/tf_aws_secret_access_key_payload.json \
  https://app.terraform.io/api/v2/workspaces/ws-UTRy8ynRv88ztF1T/vars \
  | jq '.'

{
  ... snip ...
}
```
