#!/bin/bash

echo "The crawler"
echo "use 'what' to see available commands"


what_command()
{
            echo "what - this command - shows all available commands"
            echo "help 'command' - command use instructions"
            echo "exit - close crawler"
}

help_command()
{
    if [ -z "$1" ]; then
        echo "Missing argument. Check command 'what'"
    else
        echo "might tell you how to use it."
    fi
}

user_check() {

    username="$1"

    if [ -z "$username" ]; then
        echo "Missing username"
        return
    fi

    echo "Searching for username: $username"
    echo "--------------------------------"

    sites=(
        "https://github.com/$username"
        "https://reddit.com/user/$username"
        "https://twitter.com/$username"
        "https://instagram.com/$username"
        "https://tiktok.com/@$username"
        "https://pinterest.com/$username"
        "https://youtube.com/@$username"
    )

    for url in "${sites[@]}"; do

        status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

        if [ "$status" = "200" ]; then
            echo "[FOUND] $url"
        else
            echo "[----] $url"
        fi

    done
}

while true; do
    read -p "pp>>:" command arg1 arg2
    
    case $command in
        
        what)
            what_command
            ;;
        
        help)
            help_command "$arg1"
            ;;

        exit)
            echo "Bye"
            break
            ;;
        
        user)
            user_check "$arg1"
            ;;

           *)
            echo "Unknown command"
            ;;
    esac
            

done
