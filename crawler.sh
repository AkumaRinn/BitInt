#!/bin/bash


source logo.sh

print_logo

# Ensure tmp folder exists - to store tmp data that can be saved into profiles
mkdir -p tmp
# Make sure temporary files exist and are empty
: > tmp/last_links.txt
: > tmp/last_emails.txt

#################### Internal Information ####################

what_command()
{
            echo ""
            echo "	what - this command - shows all available commands"
            echo "	help 'command' - command use instructions"
            echo "	user - search for username on preset websites"
            echo "	exit - close crawler"
            echo "	create_profile 'name' - create new profile"
            echo "	profiles - list all created profiles"
            echo "	profile 'name' - echo info for profile"
            echo "	add_links 'profile' - save found accounts links to local profile"
            echo "	add_note 'profile' - add note to local profile"
            echo ""
}

help_command()
{
    if [ -z "$1" ]; then
        echo "Missing argument. Check command 'what'"
    else
        echo "might tell you how to use it."
    fi
}

clear_f()
{
    command clear
    print_logo
}

#################### Internal files structure ####################

##### Profile #####

create_profile() {

    profile="$arg1"

    mkdir -p "profiles/$profile"

    touch profiles/$profile/links.txt
    touch profiles/$profile/emails.txt
    touch profiles/$profile/notes.txt

    echo "Profile '$profile' created."
}

show_profile() {

    profile="$1"

    if [ ! -d "profiles/$profile" ]; then
        echo "Profile not found"
        return
    fi
    
    echo ""
    echo "Profile: $profile"
    echo "----------------"

    echo "Notes:"
    cat profiles/$profile/notes.txt
    echo ""
    echo "E-mail/s:"
    cat profiles/$profile/emails.txt
    echo ""
    echo "Links:"
    cat profiles/$profile/links.txt
    echo ""
}

list_profiles()
{
    if [ ! -d "profiles" ]; then
        echo "No profiles directory found."
        return
    fi

    echo ""
    echo "Available profiles:"
    ls -1 profiles/
}


##### Manage Data #####

#Add found account links to an existing profile

add_links() {

    profile="$arg1"

    if [ ! -d "profiles/$profile" ]; then
        echo "Profile not found"
        return
    fi

    cat tmp/last_links.txt >> profiles/$profile/links.txt

    echo "Links added to profile '$profile'"
}


add_note() {

    profile="$arg1"

    if [ ! -d "profiles/$profile" ]; then
        echo "Profile not found"
        return
    fi

    shift

    note="$*"

    echo "$note" >> profiles/$profile/notes.txt
}

#################### Performable actions [to find information] ####################


##### User Search #####

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

    #clear previous results saved in tmp
    > tmp/last_links.txt

    generate_variations "$username"

    sites=(
        "https://www.linkedin.com/"
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
                echo "$url" >> tmp/last_links.txt # add found link to tmp
            fi

        done
        echo ""
    done
}



#################### Main Loop ####################

while true; do
    read -p "bitint-#: " command arg1 arg2
    
    case $command in
        
        what)
            what_command
            ;;
        
        help)
            help_command "$arg1"
            ;;
    
        clear)
            clear_f
            ;;

        exit)
            echo "Bye"
            break
            ;;
        
        user)
            user_check "$arg1"
            ;;

        create_profile)
            create_profile "$arg1"
            ;;

        profile)
            show_profile "$arg1"
            ;;

       profiles)
            list_profiles
            ;;

        add_links)
            add_links "$arg1$"
            ;;

        add_note)
            add_note "$arg1"
            ;;

           *)
            echo "Unknown command"
            ;;
    esac
            

done
