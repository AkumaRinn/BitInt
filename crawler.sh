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
        *)
            echo "Unknown command"
            ;;

    esac
            

done
