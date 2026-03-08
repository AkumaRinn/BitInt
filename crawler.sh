#!/bin/bash

echo "The crawler"
echo "use 'what' to see available commands"


what_command()
{
            echo "what - this command - shows all available commands"
            echo "help 'command' - command use instructions"
            echo "user - search for username on preset websites"
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

generate_variations() {

    username="$1"

    lower="$username"
    first_cap="$(tr '[:lower:]' '[:upper:]' <<< ${username:0:1})${username:1}"

    half=$(( ${#username} / 2 ))
    part1=${username:0:$half}
    part2=${username:$half}

    underscore="${part1}_${part2}"
    dot="${part1}.${part2}"
    dash="${part1}-${part2}"

    variations=(
        "$username"
        "$lower"
        "$first_cap"

        "$underscore"
        "$dot"
        "$dash"

        "${lower}1"
        "${lower}123"
        "${lower}99"

        "${underscore}1"
        "${underscore}99"

        "${part2}_${part1}"
        "${part2}.${part1}"

        "${lower}_"
        "_${lower}"
    )
}



user_check() {

    username="$1"

    if [ -z "$username" ]; then
        echo "Missing username"
        return
    fi

    generate_variations "$username"

    sites=(
        "https://github.com/"
        "https://reddit.com/user/"
        "https://instagram.com/"
        "https://twitter.com/"
        "https://tiktok.com/@"
        "https://pinterest.com/"
    )

    for name in "${variations[@]}"; do

        echo ""
        echo "Checking: $name"

        for site in "${sites[@]}"; do

            url="${site}${name}"

            status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

            if [ "$status" = "200" ]; then
                echo "[FOUND] $url"
            else
                echo "[...]"
            fi

        done

    done
}



#Main Loop

while true; do
    read -p "bitint-#:" command arg1 arg2
    
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
