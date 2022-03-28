#!/bin/bash

#Checking AWS CLI is installed
if [ ! -x "$(command -v aws)" ]; then
    echo "Downloading AWS CLI"
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    echo "Installing AWS CLI"
    sudo installer -pkg AWSCLIV2.pkg -target /
fi
if [ ! -x "$(command -v jq)" ]; then
    if [ ! -x "$(command -v brew)" ]; then
        if [ -x "$(command -v curl)" ]; then
            echo "We need you to be a root to install brew in your Mac"
            sudo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
        else
            echo "Install curl in you PC please!"
            exit
        fi
    fi
    echo "Installing JQ"
    brew install jq
fi
echo -e "\nType your AWS profile's name:"
read profile
if [ -z $profile ]; then
    echo "Empty string is not allowed"
else
    aws configure --profile $profile
    export AWS_PROFILE=$profile
    echo "Creating terraform User"
    user=$(aws iam create-user --user-name terraform)
    if [ -z $user ]; then
        echo "An error has occurred, please solve it and try again"
    else
        echo "terraform user created correctly"
        echo "${user}"
        echo "Please MAKE SURE the new terraform user has been added as Trusted entities in the main DevOps AWS account in the Jam3DevOpsDNSZoneAdminRole."
        userArn=$( echo $user | jq '.User.Arn' )
        echo "Updating spa-iam-role-trust-policy.json"
        tmp=$(mktemp)
        jq ".Statement.Principal.AWS = ${userArn}" spa-iam-role-trust-policy.json > "$tmp" && mv "$tmp" spa-iam-role-trust-policy.json
        echo "Creating Role terraformRole"
        sleep 10
        role=$(aws iam create-role --role-name terraformRole --assume-role-policy-document file://spa-iam-role-trust-policy.json)
        if [ -z $role ]; then
            echo "An error has occurred, please solve it and try again"
        else
            echo "terraformRole role created correctly"
            echo "${role}"
            echo "Attaching the AdministratorAccess policy to the terraformRole role"
            aws iam attach-role-policy --role-name terraformRole --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
            echo "Policy attached correctly"
            echo "Creating assumeTerraformRolePolicy"
            policy=$(aws iam create-policy --policy-name assumeTerraformRolePolicy --policy-document file://spa-iam-assume-role-policy.json)
            if [ -z $policy ]; then
                echo "An error has occurred, please solve it and try again"
            else
                echo "assumeTerraformRolePolicy created correctly"
                echo "${policy}"
                policyArn=$( echo $policy | jq '.Policy.Arn' | tr -d \")
                echo "Attaching policy to terraform user"
                aws iam attach-user-policy --user-name terraform --policy-arn "${policyArn}"
                echo "Policy attached correctly"
                echo "Creating Access Key"
                accessKey=$(aws iam create-access-key --user-name terraform)
                if [ -z $accessKey ]; then
                    echo "An error has occurred, please solve it and try again"
                else
                    echo $accessKey
                    echo "Access key created successfully"
                    echo "Please MAKE SURE you save access key's data somewhere as you won't be able to see this info again"
                    echo "Process completed successfully!!!!!"
                fi
            fi
        fi
    fi
fi
