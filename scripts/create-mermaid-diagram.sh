# ensure yj is present
if [ ! -f ~/yj ]; then
    echo "Installing yj"
    wget https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64 -O ~/yj
    chmod +x ~/yj
fi


# ensure jq is installed
jq_installed=$(which jq | grep -o jq > /dev/null &&  echo 0 || echo 1)

if [ $jq_installed = 1 ]; then
    echo "Jq is not installed. You may be prompted for a password to install it now"
    sudo apt update && sudo apt install jq
fi

# convert hcl to json
~/yj -c < ./environments/prod/prod.tfvars > /tmp/prod.json

# remove unnecessary keys, values and empty brackets
jq 'del(.enrollment_account_name)' /tmp/prod.json > /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json
jq 'del(.add_service_connection_to_ado)' /tmp/prod.json > /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json
jq 'del(.[] | .[] | . | .[] | .[] | .)' /tmp/prod.json > /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json
jq '.[]|=.[0]' /tmp/prod.json >> /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json
jq '. | keys[] as $k | "\($k), \(.[$k])"' /tmp/prod.json >> /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json

# remove any empty management groups to prevent cross linking
grep -vE '\{\}' /tmp/prod.json >> /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json

# format the json into mermaid
sed -i 's/{//g; s/}//g; s|[][]| |g; s/\, / --> /g; s/\,/ --- /g; s/\"//g; s/\\//g; s/://g' /tmp/prod.json

# rename management groups
sed -i 's/cft_non_production_subscriptions/CFT-NonProd/g; s/cft_production_subscriptions/CFT-Prod/g; s/cft_sandbox_subscriptions/CFT-Sandbox/g; s/crime_subscriptions/Crime/g; s/heritage_non_production_subscriptions/Heritage-NonProd/g; s/heritage_production_subscriptions/Heritage-Prod/g; s/heritage_sandbox_subscriptions/Heritage-Sandbox/g; s/platform_non_production_subscriptions/Platform-NonProd/g; s/platform_production_subscriptions/Platform-Prod/g; s/platform_sandbox_subscriptions/Platform-Sandbox/g; s/sds_non_production_subscriptions/SDS-NonProd/g; s/sds_production_subscriptions/SDS-Prod/g; s/sds_sandbox_subscriptions/SDS-Sandbox/g; s/security_subscriptions/Security/g; s/vh_subscriptions/VH/g' /tmp/prod.json

# add diagram hierarchy
sed -i '1s/^/```mermaid\ngraph TD\nRoot --> HMCTS\nHMCTS --> CFT\nHMCTS --> SDS\nHMCTS --> Crime\nHMCTS --> Heritage\nHMCTS --> Security\nHMCTS --> Platform\nHMCTS --> VH\nCFT --> CFT-NonProd\nCFT --> CFT-Prod\nCFT --> CFT-Sandbox\nSDS --> SDS-NonProd\nSDS --> SDS-Prod\nSDS --> SDS-Sandbox\nHeritage --> Heritage-NonProd\nHeritage --> Heritage-Prod\nHeritage --> Heritage-Sandbox\nPlatform --> Platform-NonProd\nPlatform --> Platform-Prod\nPlatform --> Platform-Sandbox\'$'\n/g' /tmp/prod.json

# add mermaid code block to json
echo "\`\`\`" >> /tmp/prod.json

# replace current mermaid code block in README with updated content
sed -i -e '/```mermaid/{:a; N; /\n```$/!ba; r /tmp/prod.json' -e 'd;}' README.md