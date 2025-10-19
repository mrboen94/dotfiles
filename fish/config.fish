# --- Greeting ---
set -U fish_greeting
function fish_greeting
    echo Oops, here I go (set_color red)hacking(set_color normal) again!
    echo The time is (set_color yellow; date +%T; set_color normal)
end

function is_os --argument-names expected_os
    string match -q "$expected_os" (string lower (uname))
end

set -l current_os (string lower (uname))

# --- Pyenv ---
if command -v pyenv > /dev/null
    pyenv init - | source
else
    echo "fish: pyenv command not found. Skipping pyenv initialization."
end

# --- FNM ---
if command -v fnm > /dev/null
    fnm env --shell fish --use-on-cd | source
else
    echo "fish: fnm command not found. Skipping fnm initialization."
end

# --- Aliases ---
alias l="ls -la"
alias gs="git status"
alias vim="nvim"
alias vi="nvim"
alias confish="nvim $HOME/.config/fish/config.fish"
alias convim="nvim $HOME/.config/nvim/init.lua"
alias convimp="nvim $HOME/.config/nvim/lua/"
alias fed="cd $HOME/.config/"
alias projects="cd $HOME/Projects/"
alias work="cd $HOME/Work/"
alias cloudWork="cd $HOME/Documents/Work/Learniken/"
alias cloudProjects="cd $HOME/Documents/Projects/"

switch $current_os
    case darwin
        if test -e "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
            alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
        else if command -v tailscale > /dev/null
            alias tailscale="tailscale"
        end
    case '*'
        if command -v tailscale > /dev/null
            alias tailscale="tailscale"
        end
end

alias az-log="func azure functionapp logstream"
alias az-get-set="func azure functionapp fetch-app-settings"
alias az-decrypt="func settings decrypt"
alias az-encrypt="func settings encrypt"
alias az-list="func azure functionapp list-functions"
alias az-publish="func azure functionapp publish"
alias shadd="npx shadcn-ui@latest add"
alias start-cluster="docker run --name sftestcluster -d -v /var/run/docker.sock:/var/run/docker.sock -p 19080:19080 -p 19000:19000 -p 25100-25200:25100-25200 mysfcluster --platform"

function az-help
    printf '%s\n' \
        "az-list: Lists functions in azure function." \
        "az-get-set <APP-NAME>: Loads settings (environment and hostfile) from azure cloud" \
        "az-decrypt: Decrypts local.settings.json and updates isEncrypted value" \
        "az-encrypt: Encrypts local.settings.json and updates isEncrypted value" \
        "az-log <APP_NAME>: Connect to logstream" \
        "az-publish <APP_NAME>: Publish function to azure"
end

if test -S "$HOME/.1password/agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
else
    if set -q SSH_AUTH_SOCK && test "$SSH_AUTH_SOCK" = "$HOME/.1password/agent.sock"
        set -e SSH_AUTH_SOCK
    end
end

if test -d "/usr/local/go/bin"; fish_add_path "/usr/local/go/bin"; end
if test -d "$HOME/go/bin"; fish_add_path "$HOME/go/bin"; end

if test -d /opt/homebrew; and test (arch) = "arm64"; and test "$current_os" = "Darwin"
  set -gx HOMEBREW_PREFIX "/opt/homebrew";
  set -gx HOMEBREW_CELLAR "/opt/homebrew/Cellar";
  set -gx HOMEBREW_REPOSITORY "/opt/homebrew";
  set -q PATH; or set PATH ''; set -gx PATH "/opt/homebrew/bin" "/opt/homebrew/sbin" $PATH;
  set -q MANPATH; or set MANPATH ''; set -gx MANPATH "/opt/homebrew/share/man" $MANPATH;
  set -q INFOPATH; or set INFOPATH ''; set -gx INFOPATH "/opt/homebrew/share/info" $INFOPATH;
  fish_add_path /opt/homebrew/bin
  set -gx HOMEBREW_NO_ENV_HINTS 1
end

if status is-interactive
    if command -v starship > /dev/null
        set -gx STARSHIP_CONFIG "$HOME/.config/wezterm/starship.toml"
        starship init fish | source
    else
        echo "fish: starship command not found. Skipping Starship initialization."
    end

    if command -v fnm > /dev/null
        fnm env --use-on-cd | source
    end

    set -g theme_color_scheme nord
end

function ..
    cd ..
end
function ...
    cd ../..
end
function ....
    cd ../../..
end

if test -f "$HOME/.config/op/plugins.sh"
    source "$HOME/.config/op/plugins.sh"
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
fish_add_path $HOME/.local/bin
