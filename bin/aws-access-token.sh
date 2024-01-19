#!/bin/bash
#
# Script to deal with MFA -protected api calls.
#
# Typical usage:
#
# eval $(aws-access-token -p PROFILE)
#
# This will prompt for a token, which you can get from
# google authenticator.
#
Usage="Usage: $0 -p aws_profile_name"

# My serial number
SERIAL="arn:aws:iam::452795580683:mfa/aqpeeb@gmail.com"
# SERIAL="arn:aws:iam::958406466453:mfa/AndrewPeebles"

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

# Prompt for the token
echo -n "MFA code: ">/dev/stderr
read token

cmd="aws --profile $profile_name sts get-session-token --serial-number $SERIAL --token-code $token --output text"

text=`$cmd`
key=$(echo $text|awk '{print $2}')
secret=$(echo $text|awk '{print $4}')
session=$(echo $text|awk '{print $5}')

## add AWS_REGION
# parse the $HOME/.aws/config file.
function parse_aws {
    cat $1 | grep -v ^# | awk -F' ' '{
if ( $1 == "[default]" ) { profile="default"; }
else if ( substr($1,0,8) == "[profile" ) { profile=$2; gsub(/[\[\]]/,"",profile); }
else if ( substr($1,0,1) == "[" ) { profile=$1; gsub(/[\[\]]/,"",profile); }
else { printf("%s_%s=\"%s\"\n", profile, $1, $3); }
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

Region=$(aws_value $profile_name "region")

echo "export AWS_ACCESS_KEY_ID=\"$key\""
echo "export AWS_SECRET_ACCESS_KEY=\"$secret\""
echo "export AWS_SESSION_TOKEN=\"$session\""
echo "export AWS_REGION=\"$Region\""

