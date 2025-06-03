# ~/.config/fish/config.fish

# --- Greeting ---
# Clears the default Fish greeting.
set -U fish_greeting
# Custom greeting function
function fish_greeting
    echo Oops, here I go (set_color red)hacking(set_color normal) again!
    echo The time is (set_color yellow; date +%T; set_color normal)
end

# --- Pyenv (Python Version Management) ---
# Initializes pyenv if it's installed.
# Make sure pyenv is installed and configured correctly for this to work.
if command -v pyenv > /dev/null
    pyenv init - | source
else
    echo "fish: pyenv command not found. Skipping pyenv initialization."
end

# --- FNM (Node.js Version Management) ---
# Initializes fnm if it's installed.
# This should handle Node.js and npm paths automatically.
if command -v fnm > /dev/null
    fnm env --shell fish --use-on-cd | source
else
    echo "fish: fnm command not found. Skipping fnm initialization."
end

# --- (Commented Out) Original fnm node version update ---
# The following function 'set_node_version' attempts to symlink Node.js binaries
# to /usr/local/bin. This is generally not recommended when using a version
# manager like fnm, as fnm handles path management through shims.
# This can also lead to permission issues as /usr/local/bin often requires sudo.
# If fnm is correctly initialized (see above), this function is likely unnecessary.
#
# function set_node_version
#     echo "INFO: 'set_node_version' is generally not needed with fnm."
#     echo "Consider removing this function if fnm manages your Node.js versions."
#     # The following lines might require sudo and could conflict with fnm:
#     # ln -s "$(which node)" /usr/local/bin/node
#     # ln -s "$(which npm)" /usr/local/bin/npm
# end

# --- Aliases ---
alias l="ls -la"
alias gs="git status"
alias vim="nvim" # Assumes nvim is your preferred editor
alias vi="nvim"  # Alias vi to nvim as well

# Config file editing aliases (using $HOME for portability)
alias confish="nvim \$HOME/.config/fish/config.fish"
alias convim="nvim \$HOME/.config/nvim/init.lua"
alias convimp="nvim \$HOME/.config/nvim/lua/"
alias fed="cd \$HOME/.config/"

# Directory navigation aliases (using $HOME for portability)
# Ensure these directories exist under $HOME/Documents or adjust as needed.
alias projects="cd \$HOME/Documents/Projects/"
alias work="cd \$HOME/Documents/Work/"
# Example project/client specific aliases - adjust paths as necessary
alias learniken="cd \$HOME/Documents/Work/Learniken/"
alias dedicare="cd \$HOME/Documents/Work/Dedicare"
alias housing="cd \$HOME/Documents/Work/Dedicare Housing"

# Homebrew aliases (these will only work if Homebrew is installed and in PATH)
if command -v brew > /dev/null
    alias bi="brew install"
    alias bu="brew uninstall"
else
    # Optional: define dummy aliases or messages if brew is not found
    # alias bi="echo 'brew not found. Cannot run brew install.'"
    # alias bu="echo 'brew not found. Cannot run brew uninstall.'"
end

# Tailscale alias (OS-dependent)
if status is-darwin
    # macOS specific path for Tailscale application
    if test -e "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
        alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
    else if command -v tailscale > /dev/null
        # If app bundle not found, but 'tailscale' is in PATH
        alias tailscale="tailscale"
    end
else if command -v tailscale > /dev/null
    # For Linux and other OS, assume 'tailscale' is in PATH
    alias tailscale="tailscale"
end

# Azure CLI function aliases (assumes 'func' command is in PATH)
alias az-log="func azure functionapp logstream"
alias az-get-set="func azure functionapp fetch-app-settings"
alias az-decrypt="func settings decrypt"
alias az-encrypt="func settings encrypt"
alias az-list="func azure functionapp list-functions"
alias az-publish="func azure functionapp publish"

# Other development aliases
alias shadd="npx shadcn-ui@latest add"
alias start-cluster="docker run --name sftestcluster -d -v /var/run/docker.sock:/var/run/docker.sock -p 19080:19080 -p 19000:19000 -p 25100-25200:25100-25200 mysfcluster --platform" # Ensure 'mysfcluster' image is available

# --- Help Functions ---
function az-help
    printf '%s\n' \
        "az-list: Lists functions in azure function." \
        "az-get-set <APP-NAME>: Loads settings (environment and hostfile) from azure cloud" \
        "az-decrypt: Decrypts local.settings.json and updates isEncrypted value" \
        "az-encrypt: Encrypts local.settings.json and updates isEncrypted value" \
        "az-log <APP_NAME>: Connect to logstream" \
        "az-publish <APP_NAME>: Publish function to azure"
end

function alias-help
    set_color cyan; echo "Aliases:"; set_color normal

    # Helper to print alias lines
    function _print_alias
        printf '  %s%s: %s%s\n' (set_color $argv[1]) $argv[2] $argv[3] (set_color normal)
    end

    _print_alias green "l" "ls -la"
    if command -v brew > /dev/null
        _print_alias green "bi" "brew install"
        _print_alias green "bu" "brew uninstall"
    end
    _print_alias green "gs" "git status"
    _print_alias green "confish" "nvim \$HOME/.config/fish/config.fish"
    _print_alias green "convim" "nvim \$HOME/.config/nvim/init.lua"
    _print_alias green "convimp" "nvim \$HOME/.config/nvim/lua/"
    _print_alias green "vim" "nvim"
    _print_alias green "vi" "nvim"
    _print_alias green "fed" "cd \$HOME/.config/"
    _print_alias green "projects" "cd \$HOME/Documents/Projects/"
    _print_alias green "work" "cd \$HOME/Documents/Work/"
    _print_alias green "learniken" "cd \$HOME/Documents/Work/Learniken/"
    _print_alias green "dedicare" "cd \$HOME/Documents/Work/Dedicare"
    _print_alias green "housing" "cd \$HOME/Documents/Work/Dedicare Housing"

    if status is-darwin && test -e "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
        _print_alias green "tailscale" "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
    else if command -v tailscale > /dev/null
        _print_alias green "tailscale" "tailscale (from PATH)"
    end

    _print_alias blue "az-log" "func azure functionapp logstream"
    _print_alias blue "az-get-set" "func azure functionapp fetch-app-settings"
    _print_alias blue "az-decrypt" "func settings decrypt"
    _print_alias blue "az-encrypt" "func settings encrypt"
    _print_alias blue "az-list" "func azure functionapp list-functions"
    _print_alias blue "az-publish" "func azure functionapp publish <APP_NAME>"
    _print_alias red "shadd" "npx shadcn-ui@latest add <COMPONENT_NAME>"
    _print_alias red "start-cluster" "Starts Microsoft Service Fabric Cluster docker container"
end

# --- 1Password SSH Agent ---
# Configure SSH to use 1Password's agent if the socket exists.
if test -S "$HOME/.1password/agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
else
    # Fallback or clear if not found, to avoid issues with stale settings
    if set -q SSH_AUTH_SOCK && test "$SSH_AUTH_SOCK" = "$HOME/.1password/agent.sock"
        set -e SSH_AUTH_SOCK
    end
end

# --- Go Environment ---
# Add Go binary directories to PATH if they exist.
# Common Go paths: /usr/local/go/bin (system-wide) and $HOME/go/bin (user-specific).
if test -d "/usr/local/go/bin"; fish_add_path "/usr/local/go/bin"; end
if test -d "$HOME/go/bin"; fish_add_path "$HOME/go/bin"; end

# --- Homebrew Path Configuration ---
# Sets up Homebrew paths based on OS and architecture.
# Common setting for all Homebrew instances
set -gx HOMEBREW_NO_ENV_HINTS 1

if status is-darwin
    if test (uname -m) = "arm64" # Apple Silicon macOS
        set HOMEBREW_BASE_PATH "/opt/homebrew"
        if test -d "$HOMEBREW_BASE_PATH/bin"
            fish_add_path "$HOMEBREW_BASE_PATH/bin"
            fish_add_path "$HOMEBREW_BASE_PATH/sbin" # Add sbin if it exists and is needed
            set -gx HOMEBREW_PREFIX "$HOMEBREW_BASE_PATH"
            set -gx HOMEBREW_CELLAR "$HOMEBREW_BASE_PATH/Cellar"
            set -gx HOMEBREW_REPOSITORY "$HOMEBREW_BASE_PATH"
            # MANPATH and INFOPATH (optional, fish_add_path and brew often handle this)
            if test -d "$HOMEBREW_BASE_PATH/share/man"; and not string match -q -- "*$HOMEBREW_BASE_PATH/share/man*" "$MANPATH"
                set -pga MANPATH "$HOMEBREW_BASE_PATH/share/man"
            end
            if test -d "$HOMEBREW_BASE_PATH/share/info"; and not string match -q -- "*$HOMEBREW_BASE_PATH/share/info*" "$INFOPATH"
                set -pga INFOPATH "$HOMEBREW_BASE_PATH/share/info"
            end
        end
    else # Intel macOS
        set HOMEBREW_INTEL_PATHS "/usr/local/bin" "/usr/local/sbin" # Default for Intel
        if test -d "/usr/local/Homebrew/bin"; set -a HOMEBREW_INTEL_PATHS "/usr/local/Homebrew/bin"; end # Alternative Intel path
        for path_to_add in $HOMEBREW_INTEL_PATHS
            if test -d $path_to_add
                fish_add_path $path_to_add
            end
        end
    end
else if status is-linux
    # Linuxbrew common paths
    if test -d "$HOME/.linuxbrew/bin" # User installation
        fish_add_path "$HOME/.linuxbrew/bin"
        fish_add_path "$HOME/.linuxbrew/sbin"
    else if test -d "/home/linuxbrew/.linuxbrew/bin" # System-wide installation
        fish_add_path "/home/linuxbrew/.linuxbrew/bin"
        fish_add_path "/home/linuxbrew/.linuxbrew/sbin"
    end
end

# --- Interactive Session Setup ---
if status is-interactive
    # Starship Prompt (ensure Starship is installed)
    if command -v starship > /dev/null
        set -gx STARSHIP_CONFIG "$HOME/.config/wezterm/starship.toml" # Assumes this path is correct
        starship init fish | source
    else
        echo "fish: starship command not found. Skipping Starship initialization."
    end

    # FNM environment (re-source for interactive, though already done above,
    # this is common practice in some configs for interactive-specific settings)
    if command -v fnm > /dev/null
        fnm env --use-on-cd | source
    end

    # Theme (example, customize as needed)
    set -g theme_color_scheme nord # This is a fish internal variable, not for all themes
end

# --- Utility Functions ---
function ..
    cd ..
end
function ...
    cd ../..
end
function ....
    cd ../../..
end

# --- (Commented Out) Python 3.11 System Path ---
# The following line adds a specific Python version to the PATH.
# This is generally not recommended if you are using pyenv, as pyenv
# should manage your Python versions and paths.
# This path is also macOS-specific.
#
# set -x PATH "/Library/Frameworks/Python.framework/Versions/3.11/bin" "$PATH"

# --- 1Password CLI Plugins ---
# Source 1Password CLI plugins if the script exists.
if test -f "$HOME/.config/op/plugins.sh"
    source "$HOME/.config/op/plugins.sh"
end

# --- Final Checks and Cleanups ---
# Example: Ensure PATH doesn't have duplicates (fish_add_path handles this)
# You can add other universal settings or cleanups here.

# echo "Fish config loaded. For help with aliases, type 'alias-help'. For Azure CLI functions, type 'az-help'."
