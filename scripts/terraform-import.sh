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

subscriptions='[
        {
            "subscription_name": "DCD-CFT-Sandbox", "deploy_acme": "true", "environment": "sbox"
        }
    ]'

for subscription in $(echo "${subscriptions[@]}" | jq -c '.[]'); do

    # get subscription name
    SUBSCRIPTION_NAME=$(echo $subscription | jq -r '.subscription_name')
    echo "SUBSCRIPTION_NAME is $SUBSCRIPTION_NAME"

    # get subscription id
    SUBSCRIPTION_ID=$(az account subscription list --query "[?displayName=='${SUBSCRIPTION_NAME}'].{subscriptionId:subscriptionId}" --only-show-errors -o tsv)
    echo "SUBSCRIPTION_ID is $SUBSCRIPTION_ID"

    ENVIRONMENT=$(echo "${subscription}" | jq -r '.environment')
    echo "ENVIRONMENT is $ENVIRONMENT"

    # set context to HMCTS-CONTROL to get keyvault resource id
    echo "Setting Azure CLI context to subscription HMCTS-CONTROL" 
    az account set -s "HMCTS-CONTROL"
    HMCTS_CONTROL_SUBSCRIPTION_ID=$(az account subscription list --query "[?displayName=='HMCTS-CONTROL'].{subscriptionId:subscriptionId}" --only-show-errors -o tsv)

    KEYVAULT_ID=$(az keyvault show --name $(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}kv) --query '{id:id}' -o tsv)

    STORAGE_ACCOUNT_ID=$(az storage account list --query "[?name=='$(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}sa)'].{id:id}" -o tsv)

    secrets='[
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
        echo "Importing keyvault into terraform state..."
        # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault.kv $KEYVAULT_ID

        echo "Importing keyvault secrets into terraform state..."
        # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_secret.$(echo $secret | jq -r '.resource') $SECRET_ID
        
        echo "Importing storage account and container into terraform state..."
        # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_account.sa $STORAGE_ACCOUNT_ID
        # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_container.sc https://$(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}sa).blob.core.windows.net/subscription-tfstate 
    else
        echo "Key Vault secret $SECRET_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault_secret.$(echo $secret | jq -r '.resource')"
    fi
    done

    # set context to subscription for other resources
    echo "Setting Azure CLI context to subscription $SUBSCRIPTION_NAME"
    az account set -s $SUBSCRIPTION_NAME

    DEPLOY_ACME=$(echo "${subscription}" | jq -r '.deploy_acme')

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

    ADO_SERVICE_ENDPOINT="PlatformOperations/$(az devops service-endpoint list -p PlatformOperations --query "[?name=='${SUBSCRIPTION_NAME}'].{id:id}" -o tsv)"

    if [ "$1" = "--import" ]; then
        echo "Importing subscription into terraform state..."
        # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_subscription.this $ALIAS_ID

        echo "Importing application and service principal into terraform state..."
        # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_application.app $APP_ID
        # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_service_principal.sp $SP_ID

        echo "Importing ADO service endpoint into terraform state..."
        # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuredevops_serviceendpoint_azurerm.endpoint $ADO_SERVICE_ENDPOINT
 
    else
        echo "Subscription alias $ALIAS_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_subscription.this"
        echo "Application Registration $APP_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_application.app"
        echo "Service Principal $SP_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_service_principal.sp"
        echo "Azure DevOps Service Endpoint $ADO_SERVICE_ENDPOINT will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azuredevops_serviceendpoint_azurerm.endpoint"
        echo "Key vault $KEYVAULT_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault.kv"
        echo "Storage account $STORAGE_ACCOUNT_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_account.sa"
        echo "Storage container https://$(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}sa).blob.core.windows.net/subscription-tfstate will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_container.sc"
    fi

    groups='[
            {
                "resource": "Contributor",
                "group_name": "DTS Contributors"
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
                # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_group.groups[\"$GROUP\"] $GROUP_ID
                # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_role_assignment.local_groups[\"$GROUP\"] $ROLE_ID
            else
                echo "Azure AD group $GROUP_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azuread_group.groups[\"$GROUP\"]"
                echo "Role assignment $ROLE_ID will be imported to module.subscription[\"${SUBSCRIPTION_NAME}\"].azurerm_role_assignment.local_groups[\"$GROUP\"]"
            fi    
    done

    if [ "$DEPLOY_ACME" = "true" ]; then

    APP_ID=$(az ad app list --display-name "acme-"${SUBSCRIPTION_NAME} --query '[].{id:id}' -o tsv)

        if [ "$1" = "--import" ]; then

            # search for keyvault in current subscription. If it exists, it will have to be moved to HMCTS-CONTROL subscription
            KEYVAULT_ID=$(az keyvault show --name "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g') --query '{id:id}' -o tsv 2> /dev/null)

            # determine if keyvault needs moved
            KEYVAULT_RG=$(az keyvault show --name "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g') --query '{resourceGroup:resourceGroup}' -o tsv 2> /dev/null)

            if [ "$KEYVAULT_RG" == "cft-platform-${ENVIRONMENT}-rg" ]; then
            echo "ACME keyvault needs moved. Validating if resource can be moved..."
            VALIDATE_KEYVAULT=$(az resource invoke-action --action validateMoveResources --ids "$(echo $KEYVAULT_ID | sed -e 's/\/providers.*//g')" \
            --request-body "{  \"resources\": [\"$KEYVAULT_ID\"],\"targetResourceGroup\":\"/subscriptions/${HMCTS_CONTROL_SUBSCRIPTION_ID}/resourceGroups/enterprise-$ENVIRONMENT-rg\" }")
            
                if [ "$VALIDATE_KEYVAULT" = "{}" ]; then
                echo "Validation successful...moving ACME keyvault to resource group enterprise-${ENVIRONMENT}-rg"
                az resource move --destination-subscription-id ${HMCTS_CONTROL_SUBSCRIPTION_ID} --destination-group enterprise-${ENVIRONMENT}-rg --ids $KEYVAULT_ID
                fi
            fi

            # set variable to resource id of keyvault in HMCTS-CONTROL subscription
            KEYVAULT_ID="/subscriptions/${HMCTS_CONTROL_SUBSCRIPTION_ID}/resourceGroups/enterprise-${ENVIRONMENT}-rg/providers/Microsoft.KeyVault/vaults/$(echo "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g'))"
                
            # search for storage account in current subscription. If it exists, it will have to be moved to HMCTS-CONTROL subscription
            STORAGE_ACCOUNT_ID=$(az storage account list --query "[?name=='"acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')'].{id:id}" -o tsv 2> /dev/null)

            # determine if storage account needs moved
            STORAGE_RG=$(az storage account show --ids $STORAGE_ACCOUNT_ID --query '{resourceGroup:resourceGroup}' -o tsv 2> /dev/null)
            
            if [ "$STORAGE_RG" == "cft-platform-${ENVIRONMENT}-rg" ]; then
            echo "ACME storage account needs moved. Validating if resource can be moved..."
            VALIDATE_STORAGE=$(az resource invoke-action --action validateMoveResources --ids "$(echo $STORAGE_ACCOUNT_ID | sed -e 's/\/providers.*//g')" \
            --request-body "{  \"resources\": [\"$OLD_STORAGE_ACCOUNT_ID\"],\"targetResourceGroup\":\"/subscriptions/${HMCTS_CONTROL_SUBSCRIPTION_ID}/resourceGroups/enterprise-$ENVIRONMENT-rg\" }")
            
                if [ "$VALIDATE_STORAGE" = "{}" ]; then
                echo "Validation successful...moving ACME storage account to resource group enterprise-${ENVIRONMENT}-rg"
                az resource move --destination-subscription-id ${HMCTS_CONTROL_SUBSCRIPTION_ID} --destination-group enterprise-${ENVIRONMENT}-rg --ids $STORAGE_ACCOUNT_ID
                fi
            fi

            # set variable to resource id of storage account in HMCTS-CONTROL subscription
            STORAGE_ACCOUNT_ID="/subscriptions/${HMCTS_CONTROL_SUBSCRIPTION_ID}/resourceGroups/enterprise-${ENVIRONMENT}-rg/providers/Microsoft.Storage/storageAccounts/$(echo "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g'))"

            echo "Importing ACME resources into terraform state..."
            # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.acme[\"${SUBSCRIPTION_NAME}\"].azuread_application.appreg $APP_ID
            az account set -s "HMCTS-CONTROL"
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.acme[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault.kv $KEYVAULT_ID
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.acme[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_account.stg $STORAGE_ACCOUNT_ID
        else
            echo "ACME application registration $APP_ID will be imported to module.acme[\"${SUBSCRIPTION_NAME}\"].azuread_application.appreg"
            echo "ACME keyvault $(echo "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')) will be imported to module.acme[\"${SUBSCRIPTION_NAME}\"].azurerm_key_vault.kv"
            echo "ACME storage account $(echo "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')) will be imported to module.acme[\"${SUBSCRIPTION_NAME}\"].azurerm_storage_account.stg"
        fi
    fi
done
IFS=$oldIFS