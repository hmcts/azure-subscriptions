oldIFS=$IFS
IFS=$'\n'

# by default the script will assume you want a dry-run to see what resources will be imported
# pass the `--import` argument to initiate terraform import

if [ "$1" != "--import" ]; then
echo "This is a dry-run\nAppend --import to run terraform import"
fi

if [ "$1" = "--import" ]; then
    echo "You have specified the --import flag. This will perform terraform import\nRemove this flag to perform a dry-run"
    read -n1 -p "Do you wish to run terraform import? [y,n]" input 

    if [[ $input == "Y" || $input == "y" ]]; then
        echo "\nImporting resources into terraform state"
    else
        echo "\nYou have selected no. Exiting..."
        exit 1
    fi
fi

# check required az extensions are installed
extensions='[
        {
            "name": "account"
        },
        {
            "name": "azure-devops"
        }
    ]'

for extension in $(echo "${extensions[@]}" | jq -r '.[].name'); do
    AZ_EXTENSION=$(az extension list --query "[?name=='${extension}']")
    if [ "$AZ_EXTENSION" = "[]" ]; then
        echo "\nInstalling azure cli extensions..."
        az extension add --name $extension
    fi
done

az devops configure --defaults organization=https://dev.azure.com/hmcts

subscriptions=$(cat ../../scripts/subscriptions.json)

for subscription in $(echo "${subscriptions[@]}" | jq -c '.[]'); do

    # get subscription name
    SUBSCRIPTION_NAME=$(echo $subscription | jq -r '.subscription_name')
    echo "SUBSCRIPTION_NAME is $SUBSCRIPTION_NAME"

    # get subscription id
    SUBSCRIPTION_ID=$(az account subscription list --query "[?displayName=='${SUBSCRIPTION_NAME}'].{subscriptionId:subscriptionId}" --only-show-errors -o tsv)
    echo "SUBSCRIPTION_ID is $SUBSCRIPTION_ID"

    SUBSCRIPTION_RESOURCE_ID="/subscriptions/${SUBSCRIPTION_ID}"

    ENVIRONMENT=$(echo "${subscription}" | jq -r '.environment')
    echo "ENVIRONMENT is $ENVIRONMENT"

    # set context to HMCTS-CONTROL to get keyvault resource id
    echo "Setting Azure CLI context to subscription HMCTS-CONTROL" 
    az account set -s "HMCTS-CONTROL"
    HMCTS_CONTROL_SUBSCRIPTION_ID=$(az account subscription list --query "[?displayName=='HMCTS-CONTROL'].{subscriptionId:subscriptionId}" --only-show-errors -o tsv)

    KEYVAULT_ID=$(az keyvault show --name $(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}kv) --query '{id:id}' -o tsv)

    STORAGE_ACCOUNT_ID=$(az storage account list --query "[?name=='$(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}sa)'].{id:id}" -o tsv)

    CONTRIBUTORS_GROUP_ID=$(az ad group show --group "DTS Contributors (sub:${SUBSCRIPTION_NAME})" --query '{id:id}' -o tsv)

    if [ "$1" = "--import" ]; then
        echo "Importing keyvault into terraform state..."
        terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault.kv $KEYVAULT_ID

        echo "Importing keyvault access policy into terraform state..."
        terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_access_policy.permissions $KEYVAULT_ID/objectId/$CONTRIBUTORS_GROUP_ID
            
        echo "Importing storage account and container into terraform state..."
        terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_account.sa $STORAGE_ACCOUNT_ID
        terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_container.sc https://$(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}sa).blob.core.windows.net/subscription-tfstate 
    else
        echo "Key Vault $KEYVAULT_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault.kv"
        echo "Key Vault access policy $KEYVAULT_ID/objectId/$CONTRIBUTORS_GROUP_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_access_policy.permissions"
        echo "Storage account $STORAGE_ACCOUNT_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_account.sa"
        echo "Storage container https://$(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}sa).blob.core.windows.net/subscription-tfstate will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_container.sc"
    fi

    secrets='[
            {
                "resource": "aks_admin_group_id",
                "secret_name": "aks-admin-rbac-group-id"
            },
            {
                "resource": "aks_user_group_id",
                "secret_name": "aks-user-rbac-group-id"
            },
            {
                "resource": "sp_app_id",
                "secret_name": "sp-application-id"
            },
            {
                "resource": "sp_object_id",
                "secret_name": "sp-object-id"
            },
            {
                "resource": "sp_token",
                "secret_name": "sp-token"
            }
    ]'

    for secret in $(echo "${secrets[@]}" | jq -c '.[]'); do

    SECRET_NAME=$(echo $secret | jq -r '.secret_name')
    SECRET_ID=$(az keyvault secret show --name $SECRET_NAME --vault-name $(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}kv) --query '{id:id}' -o tsv)

    if [ "$1" = "--import" ]; then
        echo "Importing keyvault secrets into terraform state..."
        terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_secret.$(echo $secret | jq -r '.resource') $SECRET_ID
    else
        echo "Key Vault secret $SECRET_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_secret.$(echo $secret | jq -r '.resource')"
    fi
    done

    # set context to subscription for other resources
    echo "Setting Azure CLI context to subscription $SUBSCRIPTION_NAME"
    az account set -s $SUBSCRIPTION_NAME

    # check if alias already exists
    EXISTING_ALIAS=$(az account alias list --only-show-errors | jq --arg SUBSCRIPTION_NAME "$SUBSCRIPTION_NAME" '.value[] | select(.name==$SUBSCRIPTION_NAME)' | jq -r '.name')

    if [ -z $EXISTING_ALIAS ]; then
        echo "Creating alias for subscription ${SUBSCRIPTION_NAME}"
        az account alias create --subscription-id ${SUBSCRIPTION_ID} --name ${SUBSCRIPTION_NAME}
    else
        echo "Alias already exists for subscription ${SUBSCRIPTION_NAME}"
        ACCOUNT_ALIAS=$EXISTING_ALIAS
    fi

    ALIAS_ID="/providers/Microsoft.Subscription/aliases/${SUBSCRIPTION_NAME}"

    APP_ID=$(az ad app list --display-name "DTS Bootstrap (sub:${SUBSCRIPTION_NAME})" --query '[].{id:id}' -o tsv)

    SP_ID=$(az ad sp list --display-name "DTS Bootstrap (sub:${SUBSCRIPTION_NAME})" --query '[].{id:id}' -o tsv)
    
    GA_ID=$(az ad sp list --display-name "DTS Operations Bootstrap GA" --query '[].{id:id}' -o tsv)
    MGMT_ID=$(az ad group show --group "DTS Operations (env:mgmt)" --query '{id:id}' -o tsv)
    OPERATIONS_ID=$(az ad group show --group "DTS Operations (env:$ENVIRONMENT)" --query '{id:id}' -o tsv)

    ADO_SERVICE_ENDPOINT="PlatformOperations/$(az devops service-endpoint list -p PlatformOperations --query "[?name=='${SUBSCRIPTION_NAME}'].{id:id}" -o tsv)"

    if [ "$1" = "--import" ]; then
        echo "Importing subscription into terraform state..."
        terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_subscription.this $ALIAS_ID

        echo "Importing application and service principal into terraform state..."
        terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_application.app $APP_ID
        terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_service_principal.sp $SP_ID

        echo "Importing ADO service endpoint into terraform state..."
        terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuredevops_serviceendpoint_azurerm.endpoint $ADO_SERVICE_ENDPOINT
 
    else
        echo "Subscription alias $ALIAS_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_subscription.this"
        echo "Application Registration $APP_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_application.app"
        echo "Service Principal $SP_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_service_principal.sp"
        echo "Azure DevOps Service Endpoint $ADO_SERVICE_ENDPOINT will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azuredevops_serviceendpoint_azurerm.endpoint"
    fi

    groups='[
            {
                "resource": "Azure Kubernetes Service Cluster Admin Role",
                "group_name": "DTS AKS Administrators"
            },
            {
                "resource": "Azure Kubernetes Service Cluster User Role",
                "group_name": "DTS AKS Users"
            },
            {
                "resource": "Contributor",
                "group_name": "DTS Contributors"
            },
            {
                "resource": "Key Vault Administrator",
                "group_name": "DTS Key Vault Administrators"
            },
            {
                "resource": "Owner",
                "group_name": "DTS Owners"
            },
            {
                "resource": "Reader",
                "group_name": "DTS Readers"
            },
            {
                "resource": "Storage Blob Data Reader",
                "group_name": "DTS Blob Readers"
            }
    ]'

    for group in $(echo "${groups[@]}" | jq -c '.[]'); do

        GROUP=$(echo $group | jq -r '.resource')
        GROUP_NAME=$(echo $group | jq -r '.group_name')        
        GROUP_ID=$(az ad group show --group "${GROUP_NAME} (sub:${SUBSCRIPTION_NAME})" --query '{id:id}' -o tsv)
        ROLE_ID=$(az role assignment list --assignee ${GROUP_ID}  --role ${GROUP} --scope /subscriptions/${SUBSCRIPTION_ID} --query '[].{id:id}' -o tsv)

            if [ "$1" = "--import" ]; then
                echo "Importing groups and role assignments into terraform state..."
                terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_group.groups[\"$GROUP\"] $GROUP_ID
                terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_role_assignment.local_groups[\"$GROUP\"] $ROLE_ID
                
                if [ "$GROUP" == "Contributor" ]; then
                    echo "Importing contributor group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_group_member.members[\"$GROUP-0\"] $GROUP_ID/member/$OPERATIONS_ID
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_group_member.members[\"$GROUP-1\"] $GROUP_ID/member/$SP_ID
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_group_member.members[\"$GROUP-2\"] $GROUP_ID/member/$GA_ID
                elif [ "$GROUP" == "Reader" ]; then
                    echo "Importing reader group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_group_member.members[\"$GROUP-0\"] $GROUP_ID/member/$MGMT_ID
                fi
            
            else
                echo "Azure AD group $GROUP_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_group.groups[\"$GROUP\"]"
                echo "Role assignment $ROLE_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_role_assignment.local_groups[\"$GROUP\"]"

                if [ "$GROUP" == "Contributor" ]; then
                    echo "Principal $OPERATIONS_ID will be added to Azure AD Group $GROUP_NAME"
                    echo "Principal $SP_ID will be added to Azure AD Group $GROUP_NAME"
                    echo "Principal $GA_ID will be added to Azure AD Group $GROUP_NAME"
                elif [ "$GROUP" == "Reader" ]; then
                    echo "Principal $MGMT_ID will be added to Azure AD Group $GROUP_NAME"
                fi
            fi
    done

    roles=$(jq -n --arg DTS_Contributors "DTS Contributors (sub:${SUBSCRIPTION_NAME})" --arg DTS_Operations "DTS Operations (env:${ENVIRONMENT})" '[
            {"address": "role_assignments", "assignee": $DTS_Contributors, "role": "Key Vault Contributor", "scope": "KEYVAULT_ID"},
            {"address": "role_assignments", "assignee": "DTS Operations (env:mgmt)", "role": "Monitoring Contributor", "scope": "SUBSCRIPTION_RESOURCE_ID"},
            {"address": "role_assignments", "assignee": "DTS Operations (env:mgmt)", "role": "Network Contributor", "scope": "SUBSCRIPTION_RESOURCE_ID"},
            {"address": "role_assignments", "assignee": $DTS_Contributors, "role": "Storage Account Contributor", "scope": "STORAGE_ACCOUNT_ID"},
            {"address": "role_assignments", "assignee": $DTS_Contributors, "role": "Storage Blob Data Contributor", "scope": "STORAGE_ACCOUNT_ID"},
            {"address": "role_assignments", "assignee": $DTS_Operations, "role": "User Access Administrator", "scope": "SUBSCRIPTION_RESOURCE_ID"}
            ]')

    for role in $(echo "${roles[@]}" | jq -c '.[]'); do
        ADDRESS=$(echo $role | jq -r '.address')
        ASSIGNEE=$(az ad group show --group $(echo $role | jq -r '.assignee') --query '{id:id}' -o tsv)
        ROLE=$(echo $role | jq -r '.role')
        SCOPE=$(echo $role | jq -r '.scope')
        ROLE_ID=$(az role assignment list --assignee ${ASSIGNEE} --role ${ROLE} --scope ${!SCOPE} --query '[].{id:id}' -o tsv)

            if [ "$1" = "--import" ]; then
                echo "Importing role assignments into terraform state..."
                terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_role_assignment.local_${ADDRESS}[\"${ROLE}\"] $ROLE_ID
            else
                echo "Role assignment $ROLE with scope ${!SCOPE} and assignee \"${ASSIGNEE}\" will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_role_assignment.local_${ADDRESS}[\"${ROLE}\"]"
            fi    
    done

    DEPLOY_ACME=$(echo "${subscription}" | jq -r '.deploy_acme')

    if [ "$DEPLOY_ACME" = "true" ]; then

    APP_ID=$(az ad app list --display-name "acme-"${SUBSCRIPTION_NAME} --query '[].{id:id}' -o tsv)

        if [ "$1" = "--import" ]; then

            echo "Importing ACME resources into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_application.acme_appreg[0] $APP_ID
        else
            echo "ACME application registration $APP_ID will be imported to module.subscription.azuread_application.acme_appreg[0]"
        fi
    fi
done
IFS=$oldIFS