#!/bin/bash

while getopts ":p:" opt; do
    case $opt in
        p)
            profile_name=$OPTARG
            ;;
        \?)
            echo $Usage
            exit
            ;;
    esac
done

if [ "$profile_name" = "" ]; then
    echo $Usage;
    exit 1
fi

# parse the $HOME/.aws/config file.
function parse_aws {
    cat $1 | grep -v ^# | awk -F' ' '{
if ( $1 == "[default]" ) { profile="default"; }
else if ( substr($1,0,8) == "[profile" ) { profile=$2; gsub(/[\[\]]/,"",profile); }
else if ( substr($1,0,1) == "[" ) { profile=$1; gsub(/[\[\]]/,"",profile); }
else { gsub(/-/,"_",profile); printf("%s_%s=\"%s\"\n", profile, $1, $3); }
}'
}

# given a profile and an attribute, return
# the correct value from the $HOME/.aws/config.
function aws_value {
    local profile=$1
    local attr=$2
    pv=${profile}_${attr}
    eval "V=\$$pv"
    echo $V
}
eval $(parse_aws $HOME/.aws/config)
eval $(parse_aws $HOME/.aws/credentials)

#echo "export AWS_REGION=$(aws_value $profile_name 'region')"
#echo "export AWS_ACCESS_KEY_ID=$(aws_value $profile_name 'aws_access_key_id')"
#echo "export AWS_SECRET_ACCESS_KEY=$(aws_value $profile_name 'aws_secret_access_key')"

echo "AWS_REGION=$(aws_value $profile_name 'region')"
echo "AWS_ACCESS_KEY_ID=$(aws_value $profile_name 'aws_access_key_id')"
echo "AWS_SECRET_ACCESS_KEY=$(aws_value $profile_name 'aws_secret_access_key')"

