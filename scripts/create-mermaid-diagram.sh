brew_installed=$(which brew | grep -o brew > /dev/null &&  echo 0 || echo 1)

    if [ $brew_installed = 1 ]; then
        echo "Homebrew is missing. Please install brew before continuing"
        exit 1
    fi

platform=$(uname)

if [ $platform == "Darwin" ]; then

    packages=(gawk gsed yj jq)

    for i in "${packages[@]}"

    do
        installed=$(which $i | grep -o $i > /dev/null &&  echo 0 || echo 1)
        if [ $installed = 1 ]; then
            echo "${i} is missing! Brew will attempt to install it..."
            brew install ${i}
        else
            awk_command=$(which gawk)
            sed_command=$(which gsed)
    fi
    done

elif [ $platform == "Linux" ]; then

    packages=(awk sed yj jq)

    for i in "${packages[@]}"

    do
        installed=$(which $i | grep -o $i > /dev/null &&  echo 0 || echo 1)
        if [ $installed = 1 ]; then
            echo "${i} is missing! Brew will attempt to install it..."
            brew install ${i}
        else
            awk_command=$(which awk)
            sed_command=$(which sed)
    fi
    done
fi

# convert hcl to json
yj -c < ./environments/prod/prod.tfvars > /tmp/prod.json

# remove unnecessary keys, values and empty brackets
jq 'del(.enrollment_account_name)' /tmp/prod.json > /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json
jq 'del(.add_service_connection_to_ado)' /tmp/prod.json > /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json
jq 'del(.[] | .[] | . | .[] | .[] | .)' /tmp/prod.json > /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json
jq '.[]|=.[0]' /tmp/prod.json >> /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json
jq '. | keys[] as $k | "\($k), \(.[$k])"' /tmp/prod.json >> /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json

# # remove any empty management groups to prevent cross linking
grep -vE '\{\}' /tmp/prod.json >> /tmp/prod2.json && mv /tmp/prod2.json /tmp/prod.json

# # format the json into mermaid
$sed_command -i 's/{//g; s/}//g; s|[][]| |g; s/\, / --> /g; s/\,/ --- /g; s/\"//g; s/\\//g; s/://g' /tmp/prod.json

# # rename management groups
$sed_command -i 's/cft_non_production_subscriptions/CFT-NonProd:::mg/g; s/cft_production_subscriptions/CFT-Prod:::mg/g; s/cft_sandbox_subscriptions/CFT-Sandbox:::mg/g; s/crime_subscriptions/Crime:::mg/g; s/heritage_non_production_subscriptions/Heritage-NonProd:::mg/g; s/heritage_production_subscriptions/Heritage-Prod:::mg/g; s/heritage_sandbox_subscriptions/Heritage-Sandbox:::mg/g; s/platform_non_production_subscriptions/Platform-NonProd:::mg/g; s/platform_production_subscriptions/Platform-Prod:::mg/g; s/platform_sandbox_subscriptions/Platform-Sandbox:::mg/g; s/sds_non_production_subscriptions/SDS-NonProd:::mg/g; s/sds_production_subscriptions/SDS-Prod:::mg/g; s/sds_sandbox_subscriptions/SDS-Sandbox:::mg/g; s/security_subscriptions/Security:::mg/g; s/vh_subscriptions/VH:::mg/g' /tmp/prod.json

# # open mermaid code block and add diagram hierarchy
$sed_command -i '1s/^/```mermaid\ngraph TD\nclassDef mg stroke:#ff1100,stroke-width:4px\nRoot:::mg --> HMCTS\nHMCTS:::mg --> CFT:::mg\nHMCTS:::mg --> SDS:::mg\nHMCTS:::mg --> Crime:::mg\nHMCTS:::mg --> Heritage:::mg\nHMCTS:::mg --> Security:::mg\nHMCTS:::mg --> Platform:::mg\nHMCTS:::mg --> VH\nCFT:::mg --> CFT-NonProd:::mg\nCFT:::mg --> CFT-Prod:::mg\nCFT:::mg --> CFT-Sandbox:::mg\nSDS:::mg --> SDS-NonProd:::mg\nSDS:::mg --> SDS-Prod:::mg\nSDS:::mg --> SDS-Sandbox:::mg\nHeritage:::mg --> Heritage-NonProd:::mg\nHeritage:::mg --> Heritage-Prod:::mg\nHeritage:::mg --> Heritage-Sandbox:::mg\nPlatform:::mg --> Platform-NonProd:::mg\nPlatform:::mg --> Platform-Prod:::mg\nPlatform:::mg --> Platform-Sandbox:::mg\'$'\n/g' /tmp/prod.json

# # replace extra spaces
$sed_command -i 's/[ ][ ]*/ /g' /tmp/prod.json

# # format Crime subscriptions due to names having spaces
$sed_command -i '/^Crime/s/ --- /] --- Crime[/g' /tmp/prod.json
$sed_command -i '/^Crime/s/$/]/' /tmp/prod.json
$sed_command -i '/^Crime/s/ ]/]/g' /tmp/prod.json
$sed_command -i '/^Crime/s/ --> / --> Crime[/g' /tmp/prod.json
$awk_command -i inplace -v w='Crime\\[' '{while($0~w) sub(w,"Crime"++c)}1' /tmp/prod.json
$sed_command -i '/^Crime/s/MoJ /[MoJ /g' /tmp/prod.json
$sed_command -i '/^Crime/s/MOJ /[MOJ /g' /tmp/prod.json
$sed_command -i '/^Crime/s/CRIME-/[CRIME-/g' /tmp/prod.json

# # close mermaid code block
echo "\`\`\`" >> /tmp/prod.json

# # replace current mermaid code block in README with updated content
$sed_command -i -e '/```mermaid/{:a; N; /\n```$/!ba; r /tmp/prod.json' -e 'd;}' README.md