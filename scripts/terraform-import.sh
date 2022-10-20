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

    # ensure current user has permissions to read secrets
    USER_ID=$(az ad signed-in-user show --query '{id:id}' -o tsv)
    echo "Creating key vault access policy for current user"
    az keyvault set-policy --name $(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}kv) --object-id $USER_ID --secret-permissions get list &> /dev/null

    # ensure GA service principal has permission to key vault
    PROD_GA_ID=$(az ad sp list --display-name "DTS Operations - GA" --query '[].{id:id}' -o tsv)
    echo "Creating key vault access policy for service principal"
    az keyvault set-policy --name $(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}kv) --object-id $PROD_GA_ID --secret-permissions get list set &> /dev/null

    STORAGE_ACCOUNT_ID=$(az storage account list --query "[?name=='$(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}sa)'].{id:id}" -o tsv)

    CONTRIBUTORS_GROUP_ID=$(az ad group show --group "DTS Contributors (sub:${SUBSCRIPTION_NAME})" --query '{id:id}' -o tsv)

    STATE=$(terraform state list | grep -E "module.subscription\[\"${SUBSCRIPTION_NAME}\"\\]")

    if [ "$1" = "--import" ]; then
        if [ -z $(echo "$STATE" | grep azurerm_key_vault.kv) ]; then
            echo "Importing keyvault into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault.kv $KEYVAULT_ID
        fi

        if [ -z $(echo "$STATE" | grep azurerm_key_vault_access_policy.permissions) ]; then
            echo "Importing keyvault access policy into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_access_policy.permissions $KEYVAULT_ID/objectId/$CONTRIBUTORS_GROUP_ID
        fi

        if [ -z $(echo "$STATE" | grep azurerm_storage_account.sa) ]; then
            echo "Importing storage account into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_account.sa $STORAGE_ACCOUNT_ID
        fi

        if [ -z $(echo "$STATE" | grep azurerm_storage_container.sc) ]; then
            echo "Importing storage container into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_container.sc https://$(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}sa).blob.core.windows.net/subscription-tfstate
        fi
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
        if [[ -z $(echo "$STATE" | grep azurerm_key_vault_secret.aks_admin_group_id) && "$SECRET_NAME" == "aks-admin-rbac-group-id" ]]; then
            echo "Importing aks_admin_group_id keyvault secret into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_secret.aks_admin_group_id $SECRET_ID
        elif [[ -z $(echo "$STATE" | grep azurerm_key_vault_secret.aks_user_group_id) && "$SECRET_NAME" == "aks-user-rbac-group-id" ]]; then
            echo "Importing aks_user_group_id keyvault secret into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_secret.aks_user_group_id $SECRET_ID
        elif [[ -z $(echo "$STATE" | grep azurerm_key_vault_secret.sp_app_id) && "$SECRET_NAME" == "sp-application-id" ]]; then
            echo "Importing sp_app_id keyvault secret into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_secret.sp_app_id $SECRET_ID
        elif [[ -z $(echo "$STATE" | grep azurerm_key_vault_secret.sp_object_id) && "$SECRET_NAME" == "sp-object-id" ]]; then
            echo "Importing ap_object_id keyvault secret into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_secret.sp_object_id $SECRET_ID
        elif [[ -z $(echo "$STATE" | grep azurerm_key_vault_secret.sp_token) && "$SECRET_NAME" == "sp-token" ]]; then
            echo "Importing sp_token keyvault secret into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_secret.sp_token $SECRET_ID
        fi
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

    if [ "$SUBSCRIPTION_NAME" = "DTS-HERITAGE-EXTSVC-PROD" ]; then
        APP_ID="5f29910d-50d4-424b-a888-e95c59dc9d70"
    else 
        APP_ID=$(az ad app list --display-name "DTS Bootstrap (sub:${SUBSCRIPTION_NAME})" --query '[].{id:id}' -o tsv)
    fi

    if [ "$SUBSCRIPTION_NAME" = "DTS-HERITAGE-EXTSVC-PROD" ]; then
        SP_ID="4ef09b72-da7d-4447-a7b3-b979308c9aa2"
    else 
        SP_ID=$(az ad sp list --display-name "DTS Bootstrap (sub:${SUBSCRIPTION_NAME})" --query '[].{id:id}' -o tsv)
    fi
    
    GA_ID=$(az ad sp list --display-name "DTS Operations Bootstrap GA" --query '[].{id:id}' -o tsv)
    MGMT_ID=$(az ad group show --group "DTS Operations (env:mgmt)" --query '{id:id}' -o tsv)
    OPERATIONS_ID=$(az ad group show --group "DTS Operations (env:$ENVIRONMENT)" --query '{id:id}' -o tsv)

    ADO_SERVICE_ENDPOINT="PlatformOperations/$(az devops service-endpoint list -p PlatformOperations --query "[?name=='${SUBSCRIPTION_NAME}'].{id:id}" -o tsv)"

    if [ "$1" = "--import" ]; then

        if [ -z $(echo "$STATE" | grep -E "azurerm_subscription.this") ]; then
            echo "Importing subscription into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_subscription.this $ALIAS_ID
        fi

        if [ -z $(echo "$STATE" | grep -E "azuread_application.app") ]; then
            echo "Importing application into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_application.app $APP_ID
        fi

        if [ -z $(echo "$STATE" | grep -E "azuread_service_principal.sp") ]; then
            echo "Importing service principal into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_service_principal.sp $SP_ID
        fi

        if [ -z $(echo "$STATE" | grep -E "azuredevops_serviceendpoint_azurerm.endpoint") ]; then
            echo "Importing ADO service endpoint into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuredevops_serviceendpoint_azurerm.endpoint $ADO_SERVICE_ENDPOINT
        fi

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
        AKS_ADMIN_GROUP_ID=$(az ad group show --group "dcd_group_aks_admin_global_v2" --query '{id:id}' -o tsv)

            if [ "$1" = "--import" ]; then
                if [[ -z $(echo "$STATE" | grep -E "azuread_group.groups\\[\"Azure Kubernetes Service Cluster Admin Role\"\\]") && "$GROUP" == "Azure Kubernetes Service Cluster Admin Role" ]]; then
                    echo "Importing azure kubernetes service cluster admin role group into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group.groups\[\"$GROUP\"\] $GROUP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group.groups\\[\"Azure Kubernetes Service Cluster User Role\"\\]") && "$GROUP" == "Azure Kubernetes Service Cluster User Role" ]]; then
                    echo "Importing azure kubernetes service cluster user role group into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group.groups\[\"$GROUP\"\] $GROUP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group.groups\\[\"Contributor\"\\]") && "$GROUP" == "Contributor" ]]; then
                    echo "Importing contributor group into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group.groups\[\"$GROUP\"\] $GROUP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group.groups\\[\"Key Vault Administrator\"\\]") && "$GROUP" == "Key Vault Administrator" ]]; then
                    echo "Importing key vault administrator group into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group.groups\[\"$GROUP\"\] $GROUP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group.groups\\[\"Owner\"\\]") && "$GROUP" == "Owner" ]]; then
                    echo "Importing owner group into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group.groups\[\"$GROUP\"\] $GROUP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group.groups\\[\"Reader\"\\]") && "$GROUP" == "Reader" ]]; then
                    echo "Importing reader group into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group.groups\[\"$GROUP\"\] $GROUP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group.groups\\[\"Storage Blob Data Reader\"\\]") && "$GROUP" == "Storage Blob Data Reader" ]]; then
                    echo "Importing storage blob data reader role group into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group.groups\[\"$GROUP\"\] $GROUP_ID
                fi
            else
                echo "Azure AD group $GROUP_ID will be imported to module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group.groups\[\"$GROUP\"\]"
            fi

            if [ "$1" = "--import" ]; then
                if [[ -z $(echo "$STATE" | grep -E "azuread_group_member.members\\[\"Azure Kubernetes Service Cluster Admin Role-0\"\\]") && "$GROUP" == "Azure Kubernetes Service Cluster Admin Role" ]]; then
                    echo "Importing azure kubernetes service cluster admin role group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-0\"\] $GROUP_ID/member/$AKS_ADMIN_GROUP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group_member.members\\[\"Contributor-0\"\\]") && "$GROUP" == "Contributor" ]]; then
                    echo "Importing contributor group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-0\"\] $GROUP_ID/member/$OPERATIONS_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group_member.members\\[\"Contributor-1\"\\]") && "$GROUP" == "Contributor" ]]; then
                    echo "Importing contributor group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-1\"\] $GROUP_ID/member/$SP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group_member.members\\[\"Contributor-2\"\\]") && "$GROUP" == "Contributor" ]]; then
                    echo "Importing contributor group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-2\"\] $GROUP_ID/member/$GA_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group_member.members\\[\"Key Vault Administrator-0\"\\]") && "$GROUP" == "Key Vault Administrator" ]]; then
                    echo "Importing key vault administrator group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-0\"\] $GROUP_ID/member/$SP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group_member.members\\[\"Key Vault Administrator-1\"\\]") && "$GROUP" == "Key Vault Administrator" ]]; then
                    echo "Importing key vault administrator group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-1\"\] $GROUP_ID/member/$OPERATIONS_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group_member.members\\[\"Owner-0\"\\]") && "$GROUP" == "Owner" ]]; then
                    echo "Importing owner group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-0\"\] $GROUP_ID/member/$SP_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group_member.members\\[\"Reader-0\"\\]") && "$GROUP" == "Reader" ]]; then
                    echo "Importing reader group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-0\"\] $GROUP_ID/member/$MGMT_ID
                elif [[ -z $(echo "$STATE" | grep -E "azuread_group_member.members\\[\"Storage Blob Data Reader-0\"\\]") && "$GROUP" == "Storage Blob Data Reader" ]]; then
                    echo "Importing storage blob data reader role group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-0\"\] $GROUP_ID/member/$AKS_ADMIN_GROUP_ID
                fi
            else
                echo "Azure AD group members for group $GROUP_ID will be imported to module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azuread_group_member.members\[\"$GROUP-0\"\\]"
            fi
            
            if [ "$1" = "--import" ]; then
                if [[ -z $(echo "$STATE" | grep -E "azurerm_role_assignment.local_groups\\[\"Azure Kubernetes Service Cluster Admin Role\"\\]") && "$GROUP" == "Azure Kubernetes Service Cluster Admin Role" ]]; then
                    echo "Importing azure kubernetes service cluster admin role assignment into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azurerm_role_assignment.local_groups\[\"$GROUP\"\] $ROLE_ID
                elif [[ -z $(echo "$STATE" | grep -E "azurerm_role_assignment.local_groups\\[\"Azure Kubernetes Service Cluster User Role\"\\]") && "$GROUP" == "Azure Kubernetes Service Cluster User Role" ]]; then
                    echo "Importing azure kubernetes service cluster user role assignment into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azurerm_role_assignment.local_groups\[\"$GROUP\"\] $ROLE_ID
                elif [[ -z $(echo "$STATE" | grep -E "azurerm_role_assignment.local_groups\\[\"Contributor\"\\]") && "$GROUP" == "Contributor" ]]; then
                    echo "Importing contributor role assignment into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azurerm_role_assignment.local_groups\[\"$GROUP\"\] $ROLE_ID
                elif [[ -z $(echo "$STATE" | grep -E "azurerm_role_assignment.local_groups\\[\"Key Vault Administrator\"\\]") && "$GROUP" == "Key Vault Administrator" ]]; then
                    echo "Importing key vault administrator role assignment into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azurerm_role_assignment.local_groups\[\"$GROUP\"\] $ROLE_ID
                elif [[ -z $(echo "$STATE" | grep -E "azurerm_role_assignment.local_groups\\[\"Owner\"\\]") && "$GROUP" == "Owner" ]]; then
                    echo "Importing owner role assignment into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azurerm_role_assignment.local_groups\[\"$GROUP\"\] $ROLE_ID
                elif [[ -z $(echo "$STATE" | grep -E "azurerm_role_assignment.local_groups\\[\"Reader\"\\]") && "$GROUP" == "Reader" ]]; then
                    echo "Importing reader group members into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azurerm_role_assignment.local_groups\[\"$GROUP\"\] $ROLE_ID
                elif [[ -z $(echo "$STATE" | grep -E "azurerm_role_assignment.local_groups\\[\"Storage Blob Data Reader\"\\]") && "$GROUP" == "Storage Blob Data Reader" ]]; then
                    echo "Importing storage blob data reader role assignment into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription\[\"${SUBSCRIPTION_NAME}\"\].azurerm_role_assignment.local_groups\[\"$GROUP\"\] $ROLE_ID
                fi

            else
                echo "Role assignment $ROLE_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_role_assignment.local_groups[\"$GROUP\"]"
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
                if [[ -z $(echo "$STATE" | grep -E "azurerm_role_assignment.local_role_assignments\\[\"${ROLE}\"\\]") ]]; then
                    echo "Importing role assignments into terraform state..."
                    terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_role_assignment.local_${ADDRESS}[\"${ROLE}\"] $ROLE_ID
                fi
            else
                echo "Role assignment $ROLE with scope ${!SCOPE} and assignee \"${ASSIGNEE}\" will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_role_assignment.local_${ADDRESS}[\"${ROLE}\"]"
            fi    
    done

    DEPLOY_ACME=$(echo "${subscription}" | jq -r '.deploy_acme')

    if [ "$DEPLOY_ACME" = "true" ]; then

    APP_ID=$(az ad app list --display-name "acme-"${SUBSCRIPTION_NAME} --query '[].{id:id}' -o tsv)

        if [ "$1" = "--import" ]; then
            if [ -z $(echo "$STATE" | grep azuread_application.acme_appreg) ]; then
                echo "Importing ACME resources into terraform state..."
                terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_application.acme_appreg[0] $APP_ID
            fi
        else
            echo "ACME application registration $APP_ID will be imported to module.subscription.azuread_application.acme_appreg[0]"
        fi
    fi

    # remove user permissions to key vault
    echo "Deleting key vault access policy for current user"
    az keyvault delete-policy --name $(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}kv) --object-id $USER_ID &> /dev/null
done
IFS=$oldIFS