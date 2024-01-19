#!/bin/bash
#
# Simple release helper
#
# rel.sh [env1 env2 env3 ...]
#
# without arguments, it defaults to dev
#
function rel {
    local env="$1"
    (git checkout $env; git merge master; git push; git checkout master)
}

args="$*"
if [ "$args" = "" ]; then
    args="dev"
fi

for env in $args; do
    rel $env
done
