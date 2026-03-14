#!/bin/bash


source logo.sh

print_logo


# Move the style in a config file
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"



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
            echo "      rm 'profile' - delete profile and all its data"
            echo "	add_links 'profile' - save found accounts links to local profile"
            echo "	note 'profile' 'text' - add note to local profile"
            echo ""
}

help_command()
{
    if [ -z "$1" ]; then
        echo -e "${RED}Missing argument. Check command 'what' ${RESET}"
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

    echo -e "${GREEN}[+] Profile '$profile' created. ${RESET}"
}

show_profile() {

    profile="$1"

    if [ ! -d "profiles/$profile" ]; then
        echo -e "${RED}[!] Profile '$profile' not found ${RESET}"
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
        echo -e "${RED}[!] No profiles found. ${RESET}"
        return
    fi

    echo ""
    echo "Available profiles:"
    ls -1 profiles/
    echo ""
}

remove_profile() {

    profile="$1"

    if [ ! -d "profiles/$profile" ]; then
        echo -e "${RED}[!] Profile '$profile' not found ${RESET}"
        return
    fi

    echo -ne "${YELLOW}[*] Remove profile '$profile'?${RESET} (yes/no): "
    read -e answer

    case "$answer" in
        y|Y|yes|YES)
            rm -rf "profiles/$profile"
            echo -e "${GREEN}[-] Profile '$profile' removed.${RESET}"
            ;;
        *)
            echo -e "${GREEN}[*] Removal canceled ${RESET}"
            ;;
    esac
}


##### Manage Data #####

#Add found account links to an existing profile

add_links() {

    profile="$arg1"

    if [ ! -d "profiles/$profile" ]; then
        echo -e "${RED}[!] Profile '$profile' not found ${RESET}"
        return
    fi

    cat tmp/last_links.txt >> profiles/$profile/links.txt

    echo "Links added to profile '$profile'"
    sort -u profiles/$profile/links.txt -o profiles/$profile/links.txt
}


add_note() {

    profile="$arg1"

    if [ ! -d "profiles/$profile" ]; then
        echo -e "${RED}[!] Profile '$profile' not found ${RESET}"
        return
    fi

    shift

    note="$*"

    echo "$note" >> profiles/$profile/notes.txt
    echo -e "${GREEN}[+] Note added to profile: $profile ${RESET}"
    echo ""
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
        echo -e "${RED}[!] Missing username ${RESET}"
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
                echo -e "${GREEN}[+]Found: $url ${RESET}" 
                echo "$url" >> tmp/last_links.txt # add found link to tmp
            fi

        done
        echo ""
    done
}



#################### Main Loop ####################

while true; do
    read -p "bitint-#: " command arg1 rest
    
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

             rm)
            remove_profile "$arg1"
            ;;

        add_links)
            add_links "$arg1$"
            ;;

        note)
            add_note "$arg1" "$rest"
            ;;

           *)
            echo -e "${RED}[!] Unknown command: $command ${RESET}"
            ;;
    esac
            

done
