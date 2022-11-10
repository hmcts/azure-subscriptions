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
sed -i 's/cft_non_production_subscriptions/CFT-NonProd:::mg/g; s/cft_production_subscriptions/CFT-Prod:::mg/g; s/cft_sandbox_subscriptions/CFT-Sandbox:::mg/g; s/crime_subscriptions/Crime:::mg/g; s/heritage_non_production_subscriptions/Heritage-NonProd:::mg/g; s/heritage_production_subscriptions/Heritage-Prod:::mg/g; s/heritage_sandbox_subscriptions/Heritage-Sandbox:::mg/g; s/platform_non_production_subscriptions/Platform-NonProd:::mg/g; s/platform_production_subscriptions/Platform-Prod:::mg/g; s/platform_sandbox_subscriptions/Platform-Sandbox:::mg/g; s/sds_non_production_subscriptions/SDS-NonProd:::mg/g; s/sds_production_subscriptions/SDS-Prod:::mg/g; s/sds_sandbox_subscriptions/SDS-Sandbox:::mg/g; s/security_subscriptions/Security:::mg/g; s/vh_subscriptions/VH:::mg/g' /tmp/prod.json

# open mermaid code block and add diagram hierarchy
sed -i '1s/^/```mermaid\ngraph TD\nclassDef mg stroke:#ffffff,stroke-width:4px\nRoot:::mg --> HMCTS\nHMCTS:::mg --> CFT:::mg\nHMCTS:::mg --> SDS:::mg\nHMCTS:::mg --> Crime:::mg\nHMCTS:::mg --> Heritage:::mg\nHMCTS:::mg --> Security:::mg\nHMCTS:::mg --> Platform:::mg\nHMCTS:::mg --> VH\nCFT:::mg --> CFT-NonProd:::mg\nCFT:::mg --> CFT-Prod:::mg\nCFT:::mg --> CFT-Sandbox:::mg\nSDS:::mg --> SDS-NonProd:::mg\nSDS:::mg --> SDS-Prod:::mg\nSDS:::mg --> SDS-Sandbox:::mg\nHeritage:::mg --> Heritage-NonProd:::mg\nHeritage:::mg --> Heritage-Prod:::mg\nHeritage:::mg --> Heritage-Sandbox:::mg\nPlatform:::mg --> Platform-NonProd:::mg\nPlatform:::mg --> Platform-Prod:::mg\nPlatform:::mg --> Platform-Sandbox:::mg\'$'\n/g' /tmp/prod.json

# close mermaid code block to json
echo "\`\`\`" >> /tmp/prod.json

# replace current mermaid code block in README with updated content
sed -i -e '/```mermaid/{:a; N; /\n```$/!ba; r /tmp/prod.json' -e 'd;}' README.md