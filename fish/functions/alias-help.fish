function alias-help --description "Lists user-defined aliases and key utility functions."
    set_color $fish_color_autosuggestion; echo "User Defined Aliases";
    set_color normal;
    echo

    alias | while read -l line
        set -l parts (string replace -r '^alias ' '' -- $line)
        set -l name (string split -m1 ' ' -- $parts)[1]
        set -l definition (string sub -s (math (string length $name) + 2) -- $parts)

        if test (string sub -s 1 -l 1 -- $definition) = "'" -a (string sub -s -1 -- $definition) = "'"
            set definition (string sub -s 2 -l (math (string length $definition) - 2) -- $definition)
        end

        if test -n "$name" -a -n "$definition"
            set -l color green
            if contains $name bi bu
                set color green
            else if string match -q 'az-*' $name
                set color blue
            else if contains $name shadd start-cluster
                set color red
            else if contains $name confish convim convimp fed
                set color yellow
            else if contains $name l gs vim vi vs vsgore
                set color cyan
            end

            printf '  %s%-16s%s → %s\n' (set_color $color) $name (set_color normal) $definition
        end
    end

    echo
    set_color $fish_color_autosuggestion; echo "Functions in ~/.config/fish/functions"; set_color normal
    set_color normal
    echo

    function get_function_description --argument-names file_path
        set -l lines (head -n 10 $file_path)
        for line in $lines
            if string match -qr '^function\s+.*--description\s+["\']' -- $line
                set -l desc (string replace -r '^.*--description\s+["\']' '' -- $line | string replace -r '["\']$' '')
                echo $desc
                return
            end
        end
        echo "(no description)"
    end

    set -l func_dir ~/.config/fish/functions
    for file in (ls $func_dir | string match '*.fish')
        set -l func_name (string replace -r '\.fish$' '' -- $file)
        set -l func_path "$func_dir/$file"
        set -l desc (get_function_description $func_path)

        printf '  %s%-16s%s → %s\n' (set_color magenta) $func_name (set_color normal) $desc
    end
end
