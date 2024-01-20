function json() {
  python3 -m json.tool
}
function stack_output() {
  local profile="$1"
  local stack_name="$2"
  local name="$3"
  AWS_PROFILE=$profile aws cloudformation describe-stacks \
    --stack-name $stack_name --query 'Stacks[0].Outputs' --output text | grep $name | awk '{print $2}'
}

alias more='less'
alias deepclean='find . -name "*~" -exec rm -f {} \;'
alias ll='ls -alF'

# aws cli completer
if [ -f "/usr/local/bin/aws_completer" ]; then
    complete -C '/usr/local/bin/aws_completer' aws
fi

# Suppress annoying aws-sdk deprication warnings
export AWS_SDK_JS_SUPPRESS_MAINTENANCE_MODE_MESSAGE=1
