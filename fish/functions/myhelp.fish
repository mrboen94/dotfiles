function myhelp --description "Shows available custom help topics."
    set_color $fish_color_autosuggestion;
    set_color normal
    echo "Type one of the following commands for more details:"
    echo ""
    printf "  %s%-15s%s %s\n" (set_color blue) "alias-help" (set_color normal) "Lists user-defined aliases and key utility functions."
    printf "  %s%-15s%s %s\n" (set_color blue) "az-help" (set_color normal) "Lists Azure specific command aliases and their usage."
    echo ""
    echo "For built-in Fish help, try 'help' or 'help <command>'."
    echo "To see descriptions of specific custom functions (if provided): 'functions -D <function_name>'"
end
