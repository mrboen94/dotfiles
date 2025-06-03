function list-user-functions --description "List all user-defined Fish functions with descriptions."
    set -l func_dir ~/.config/fish/functions
    set -l funcs (ls $func_dir | string replace -r '\.fish$' '')

    for func in $funcs
        set -l path "$func_dir/$func.fish"
        set -l desc (string match -r '^function\s+.*--description\s+"(.*)"' < $path | string replace -r '^.*--description\s+"' '' | string replace -r '"$' '')

        if test -z "$desc"
            set desc "(no description)"
        end

        printf '  %s%-20s%s → %s\n' (set_color cyan) $func (set_color normal) $desc
    end
end
