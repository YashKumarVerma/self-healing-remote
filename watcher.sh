#!/bin/bash

# clean cloud links, initialize working space again
find . ! -name 'watcher.sh' -type f -exec rm -f {} +
rm -rf .git 
git init 
git remote add origin https://github.com/YashKumarVerma/self-healing-remote
git reset --hard origin/master

# hide ctrl+c from terminal
stty -echoctl 

# function called by trap
other_commands() {
    tput setaf 1
    printf "\r System Crashed !\n"

    # reset to last checkpoint
    printf "Since system crashed, reverting to last checkpoint"
    git reset --hard HEAD >> lastCommand.txt
    if [ $? -eq 0 ]; then
        printf "Successfully restored last checkpoint state\n"
    else
        printf "Error restoring last checkpoint\n"
        exit;
    fi


    printf "\rTaking system to last made checkpoint\n"
    tput sgr0
    sleep 3
    ./selfHealing
}

trap 'other_commands' SIGINT
input="$@"
while true; do
    ./selfHealing
    read input
    [[ $input == close ]] && break
    bash -c "$input"
done