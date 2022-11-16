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
$sed_command -i 's/_subscriptions//g' /tmp/prod.json
$sed_command -i 's/_sandbox/-Sandbox/g' /tmp/prod.json
$sed_command -i 's/_non_production/-NonProd/g' /tmp/prod.json
$sed_command -i 's/_production/-Prod/g' /tmp/prod.json
$sed_command -i 's/\b\(.\)/\u\1/g' /tmp/prod.json
$sed_command -i 's/Cft/CFT/g; s/Sds/SDS/g; s/Vh/VH/g' /tmp/prod.json
$sed_command -i 's/ -->/:::mg -->/g' /tmp/prod.json

# open mermaid code block and add diagram hierarchy

$awk_command -F'[:-]' '{print $1 " --> " $1"-"$2}' /tmp/prod.json > /tmp/prod2.json
while read line; do
$sed_command -i "1s/^/$line:::mg\n/g" /tmp/prod.json
done < /tmp/prod2.json
$sed_command -i '/-:::mg$/d' /tmp/prod.json

$awk_command '{print $1}' /tmp/prod.json > /tmp/prod2.json
$sed_command -i 's/:::mg//g' /tmp/prod2.json
$sed_command -i 's/\-.*$//' /tmp/prod2.json
$awk_command -i inplace '!NF || !seen[$0]++' /tmp/prod2.json 
while read line; do
$sed_command -i "1s/^/HMCTS:::mg --> $line:::mg\n/g" /tmp/prod.json
done < /tmp/prod2.json

$sed_command -i '1s/^/```mermaid\ngraph TD\nclassDef mg stroke:#ff1100,stroke-width:4px\nRoot:::mg --> HMCTS\nHMCTS:::mg -->\'$'\n/g' /tmp/prod.json
$sed_command -i '/-->$/d' /tmp/prod.json

# replace extra spaces
$sed_command -i 's/[ ][ ]*/ /g' /tmp/prod.json

# format Crime subscriptions due to names having spaces
$sed_command -i '/^Crime/s/ --- /] --- Crime[/g' /tmp/prod.json
$sed_command -i '/^Crime/s/$/]/' /tmp/prod.json
$sed_command -i '/^Crime/s/ ]/]/g' /tmp/prod.json
$sed_command -i '/^Crime/s/ --> / --> Crime[/g' /tmp/prod.json
$awk_command -i inplace -v w='Crime\\[' '{while($0~w) sub(w,"Crime"++c)}1' /tmp/prod.json
$sed_command -i '/^Crime/s/MoJ /[MoJ /g' /tmp/prod.json
$sed_command -i '/^Crime/s/MOJ /[MOJ /g' /tmp/prod.json
$sed_command -i '/^Crime/s/CRIME-/[CRIME-/g' /tmp/prod.json

# close mermaid code block
echo "\`\`\`" >> /tmp/prod.json

# replace current mermaid code block in README with updated content
$sed_command -i -e '/```mermaid/{:a; N; /\n```$/!ba; r /tmp/prod.json' -e 'd;}' README.md

