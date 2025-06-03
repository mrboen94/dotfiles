function vsgore --description 'Remove common Visual Studio build clutter (.vs/, bin/, obj/, etc.)'
    set -l patterns ".vs" "bin" "obj" "TestResults" "*.user" "*.suo" "*.cache" "*.log"
    set -l removed 0
    set -l dry_run 1

    # Check for --force flag to disable dry run
    for arg in $argv
        if test "$arg" = "--force"
            set dry_run 0
        end
    end

    echo (set_color cyan)"Running vsgore cleanup"(set_color normal)
    if test $dry_run -eq 1
        echo (set_color blue)"Dry run mode: No files will be deleted. Use --force to actually remove files."(set_color normal)
    end

    for pattern in $patterns
        for dir in (find . -type d -name $pattern -prune 2>/dev/null)
            echo (set_color yellow)"Would remove directory: $dir"(set_color normal)
            if test $dry_run -eq 0
                rm -rf "$dir"
                set removed 1
            end
        end

        for file in (find . -type f -name $pattern 2>/dev/null)
            echo (set_color red)"Would remove file: $file"(set_color normal)
            if test $dry_run -eq 0
                rm -f "$file"
                set removed 1
            end
        end
    end

    if test $dry_run -eq 1
        echo (set_color blue)"Dry run complete."(set_color normal)
    else if test $removed -eq 0
        echo (set_color green)"No vsgore found. Clean workspace!"(set_color normal)
    else
        echo (set_color green)"Cleanup complete."(set_color normal)
    end
end
