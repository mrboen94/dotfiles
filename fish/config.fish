# greeting
set -U fish_greeting
function fish_greeting
    echo Oops, here I go (set_color red)hacking(set_color normal) again!
    echo The time is (set_color yellow; date +%T; set_color normal)

end

# pyenv
pyenv init - | source

# fnm node version update
set set_node_version
function set_node_version
    ln -s "$(which node)" /usr/local/bin/node
    ln -s "$(which npm)" /usr/local/bin/npm
end

# aliases
alias l="ls -la"
alias bi="brew install"
alias bu="brew uninstall"
alias gs="git status"
alias confish="nvim /Users/mathiasboe/.config/fish/config.fish"
alias convim="nvim /Users/mathiasboe/.config/nvim/init.lua"
alias convimp="nvim /Users/mathiasboe/.config/nvim/lua/"
alias vim="nvim"
alias vi="nvim"
alias fed="cd /Users/mathiasboe/.config/"
alias projects="cd /Users/mathiasboe/Documents/Projects/"
alias work="cd /Users/mathiasboe/Documents/Work/"
alias learniken="cd /Users/mathiasboe/Documents/Work/Learniken/"
alias dedicare="cd /Users/mathiasboe/Documents/Work/Dedicare"
alias housing="cd /Users/mathiasboe/Documents/Work/Dedicare Housing"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias az-log="func azure functionapp logstream"
alias az-get-set="func azure functionapp fetch-app-settings"
alias az-decrypt="func settings decrypt"
alias az-encrypt="func settings encrypt"
alias az-list="func azure functionapp list-functions"
alias az-publish="func azure functionapp publish"
alias shadd="npx shadcn-ui@latest add"
alias start-cluster="docker run --name sftestcluster -d -v /var/run/docker.sock:/var/run/docker.sock -p 19080:19080 -p 19000:19000 -p 25100-25200:25100-25200 mysfcluster --platform"

# Learniken

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
    printf '%s\n' \
        (set_color green; echo "l: ls -la"; set_color normal) \
        (set_color green; echo "bi: brew install"; set_color normal) \
        (set_color green; echo "bu: brew uninstall"; set_color normal) \
        (set_color green; echo "gs: git status"; set_color normal) \
        (set_color green; echo "confish: nvim /Users/mathiasboe/.config/fish/config.fish"; set_color normal) \
        (set_color green; echo "convim: nvim /Users/mathiasboe/.config/nvim/init.lua"; set_color normal) \
        (set_color green; echo "convimp: nvim /Users/mathiasboe/.config/nvim/lua/"; set_color normal) \
        (set_color green; echo "vim: nvim"; set_color normal) \
        (set_color green; echo "vi: nvim"; set_color normal) \
        (set_color green; echo "fed: cd /Users/mathiasboe/.config/"; set_color normal) \
        (set_color green; echo "projects: cd /Users/mathiasboe/Documents/Projects/"; set_color normal) \
        (set_color green; echo "work: cd /Users/mathiasboe/Documents/Work/"; set_color normal) \
        (set_color green; echo "dedicare: cd /Users/mathiasboe/Documents/Work/Dedicare"; set_color normal) \
        (set_color green; echo "housing: cd /Users/mathiasboe/Documents/Work/Dedicare Housing"; set_color normal) \
        (set_color green; echo "tailscale: /Applications/Tailscale.app/Contents/MacOS/Tailscale"; set_color normal) \
        (set_color blue; echo "az-log: func azure functionapp logstream"; set_color normal) \
        (set_color blue; echo "az-get-set: func azure functionapp fetch-app-settings"; set_color normal) \
        (set_color blue; echo "az-decrypt: func settings decrypt"; set_color normal) \
        (set_color blue; echo "az-encrypt: func settings encrypt"; set_color normal) \
        (set_color blue; echo "az-list: func azure functionapp list-functions"; set_color normal)\
        (set_color blue; echo "az-publish <APP_NAME>: Publish function to azure"; set_color normal)\
        (set_color red; echo "shadd <COMPONENT_NAME>: Add Shadcn/UI component to project"; set_color normal)\
        (set_color red; echo "start-cluster: Starts Microsoft Service Fabric Cluster docker container"; set_color normal)

end

#fnm
fnm env --shell fish --use-on-cd | source

# 1Password SSH 
set SSH_AUTH_SOCK $HOME/.1password/agent.sock

# go
test -d /usr/local/go/bin; and fish_add_path /usr/local/go/bin/

# homebrew
if test -d /opt/homebrew; and test (arch) = "arm64"; and test "$os" = "Darwin"
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
    starship init fish | source
    fnm env --use-on-cd | source
    set -g theme_color_scheme nord
end

# functions
function ..; cd ..; end
function ...; cd ../..; end
function ....; cd ../../..; end

# Setting PATH for Python 3.11
# The original version is saved in /Users/mathiasboe/.config/fish/config.fish.pysave
set -x PATH "/Library/Frameworks/Python.framework/Versions/3.11/bin" "$PATH"
source ~/.config/op/plugins.sh
