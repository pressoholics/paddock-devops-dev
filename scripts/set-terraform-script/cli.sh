#!/bin/bash

#Checking AWS CLI is installed
if [ -x "$(command -v curl)" ]; then
    if [ ! -x "$(command -v jq)" ]; then
        if [ ! -x "$(command -v brew)" ]; then
            echo "We need you to be a root to install brew in your Mac"
            sudo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
        fi
        echo "Installing JQ"
        brew install jq
    fi
    echo "You should have an API token created previously in our devops account in https://app.terraform.io/"
    echo "Please enter your API Token:"
    read token
    echo "Getting oauthToken..."
    oauthToken=$(curl -s -H "Authorization: Bearer ${token}" -H "Content-Type: application/vnd.api+json" https://app.terraform.io/api/v2/organizations/pressoholics/oauth-clients | jq '.data[0].relationships."oauth-tokens".data[0].id')
    if [ "$oauthToken" == "null" ]; then
            echo "An error has occurred, check your API token is valid"
    else
        echo "Your oauthToken is ${oauthToken}"
        read -p "Enter workspace name (Ex. myfirstspa-develop): " name
        if [ -z $name ]; then
            echo "Workspace name cannot be empty"
        else
            read -p "Allow destroy plan (true/false) Default(false): " destroy
            read -p "Auto apply (true/false) Default(false): " apply
            read -p "Enter repository name (Ex. Jam3/devops-aws-spa): " repo
            if [ -z $repo ]; then
                echo "Repository cannot be empty"
            else
                read -p "Enter branch name (Ex. develop): " branch
                if [ -z $branch ]; then
                    echo "Branch cannot be empty"
                else
                    if [ "$destroy" == "true" ]; then
                        destroy=true
                    else
                        destroy=false
                    fi
                    if [ "$apply" == "true" ]; then
                        apply=true
                    else
                        apply=false
                    fi
                    tmp=$(mktemp)
                    jq --arg name "$name" --argjson destroy "$destroy" --argjson apply "$apply" --arg repo "$repo" --argjson oauthToken "$oauthToken" --arg branch "$branch"\
                    '.data.attributes.name = $name | .data.attributes."allow-destroy-plan" = $destroy | .data.attributes."auto-apply" = $apply | .data.attributes."vcs-repo".identifier = $repo | .data.attributes."vcs-repo"."oauth-token-id" = $oauthToken | .data.attributes."vcs-repo".branch = $branch' \
                    tf_workspace_payload.json > "$tmp" && mv "$tmp" tf_workspace_payload.json
                    echo "Creating Workspace..."
                    workspaceId=$(curl -s -H "Authorization: Bearer $token" -H "Content-Type: application/vnd.api+json" -X POST --data @tf_workspace_payload.json https://app.terraform.io/api/v2/organizations/pressoholics/workspaces | jq '.data.id ')
                    if [ "$workspaceId" == "null" ]; then
                        echo "An error has occurred creating the workspace, please MAKE SURE there is no any other workspace with the same name or repository you entered is correct"
                    else
                        read -p "Enter environment name (Options: [dev, stage, prod]) Default('dev'): " environment="${environment:=dev}"
                        if [ "$environment" == "dev" ]; then
                          env_file_var="-var-file=settings.dev.tfvars"
                        elif [ "$environment" == "stage" ]; then
                          env_file_var="-var-file=settings.stage.tfvars"
                        elif [ "$environment" == "prod" ]; then
                          env_file_var="-var-file=settings.prod.tfvars"
                        else
                          env_file_var="-var-file=settings.dev.tfvars"
                        fi
                        jq --arg env_file_var "$env_file_var" '.data.attributes.value = $env_file_var' tf_var_file_var_payload.json > "$tmp" && mv "$tmp" tf_var_file_var_payload.json
                        echo "Setting TF_CLI_ARGS_plan variable..."
                        url=$(echo "https://app.terraform.io/api/v2/workspaces/${workspaceId}/vars" | tr -d \")
                        varId=$(curl -s -H "Authorization: Bearer $token" -H "Content-Type: application/vnd.api+json" -X POST --data @tf_var_file_var_payload.json $url | jq '.data.id')
                        if [ "$varId" == "null" ]; then
                          echo "An error has occurred creating this TF_CLI_ARGS_plan, please remove the workspace manually and start again"
                        else
                          echo "Your workspace ID is ${workspaceId}"
                          echo "Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY variables for the IAM user that Terraform Cloud will use when provisioning AWS resources"
                          echo "Please enter your AWS_ACCESS_KEY_ID:"
                          read keyId
                          jq --arg keyId "$keyId" '.data.attributes.value = $keyId' tf_aws_access_key_payload.json > "$tmp" && mv "$tmp" tf_aws_access_key_payload.json
                          echo "Setting AWS_ACCESS_KEY_ID variable..."
                          url=$(echo "https://app.terraform.io/api/v2/workspaces/${workspaceId}/vars" | tr -d \")
                          varId=$(curl -s -H "Authorization: Bearer $token" -H "Content-Type: application/vnd.api+json" -X POST --data @tf_aws_access_key_payload.json $url | jq '.data.id')
                          if [ "$varId" == "null" ]; then
                          echo "An error has occurred creating AWS_ACCESS_KEY_ID var, please remove the workspace manually and start again"
                          else
                              echo "Please enter your AWS_SECRET_ACCESS_KEY:"
                              read secretKey
                              jq --arg secretKey "$secretKey" '.data.attributes.value = $secretKey' tf_aws_secret_access_key_payload.json > "$tmp" && mv "$tmp" tf_aws_secret_access_key_payload.json
                              varId=$(curl -s -H "Authorization: Bearer $token" -H "Content-Type: application/vnd.api+json" -X POST --data @tf_aws_secret_access_key_payload.json $url | jq '.data.id')
                              if [ "$varId" == "null" ]; then
                              echo "An error has occurred creating AWS_SECRET_ACCESS_KEY var, please remove the workspace manually and start again"
                              else
                                  echo "Process completed successfully!!!!!"
                              fi
                          fi
                        fi
                    fi
                fi
            fi
        fi

    fi
else
    echo "Install curl in you PC please!"
    # command
fi
