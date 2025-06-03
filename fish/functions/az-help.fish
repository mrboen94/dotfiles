function az-help --description "Lists Azure CLI function aliases and their usage."
    set_color $fish_color_autosuggestion; echo "Azure Function Aliases Help"; set_color normal
    printf '%s\n' \
        "az-list: Lists functions in azure function." \
        "az-get-set <APP-NAME>: Loads settings (environment and hostfile) from azure cloud" \
        "az-decrypt: Decrypts local.settings.json and updates isEncrypted value" \
        "az-encrypt: Encrypts local.settings.json and updates isEncrypted value" \
        "az-log <APP_NAME>: Connect to logstream" \
        "az-publish <APP_NAME>: Publish function to azure"
end
