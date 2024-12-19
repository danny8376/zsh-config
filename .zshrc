# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
ZSH_THEME="ozsh-theme.saru.moe"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often to auto-update? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment following line if you want to the command execution time stamp shown 
# in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git ruby bundler coffee gem npm rails screen)

check_cmd() {
    which $1 >/dev/null 2>&1 && return 0
    [[ -n "$2" ]] && [[ -f "$2" ]] && return 0
    return 1
}

append_path() {
    [[ -d "$1" ]] && export PATH="$1:$PATH"
}

is_wsl()        { [[ "$(systemd-detect-virt 2>/dev/null)" = "wsl" ]] || grep -qi Microsoft /proc/version 2>/dev/null }
is_cygwin()     { [[ "$(uname -s)" =~ ^CYGWIN_NT.* ]] }
is_msys2()      { [[ "$(uname -s)" =~ ^MSYS_NT.* ]] }
is_mingw64()    { [[ "$(uname -s)" =~ ^MINGW64_NT.* ]] }
is_mingw32()    { [[ "$(uname -s)" =~ ^MINGW32_NT.* ]] }
is_mingw()      { is_mingw64 || is_mingw32 }
is_win()        { is_wsl || is_cygwin || is_msys2 || is_mingw }

function() {
    local from
    # broken on msys2/mingw, but ignore as likely doesn't matter
    case "$(basename "$(ps -o comm= -p "$PPID" 2>/dev/null)")" in
        sshd|sshd-*|*/sshd) from="ssh";;
        mosh*)              from="mosh";;
        screen)             from="screen";;
        sudo)
            [[ -n "$STY" ]] && from="screen"
            ;;
    esac
    ZSH_TERM_FROM="$from"
}
from_ssh()      { [[ "$ZSH_TERM_FROM" = "ssh" ]] }
from_mosh()     { [[ "$ZSH_TERM_FROM" = "mosh" ]] }
from_screen()   { [[ "$ZSH_TERM_FROM" = "screen" ]] }


export PATH="$HOME/.local/bin:$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"


[[ -f ~/.zshrc.local-pre-omz ]] && source ~/.zshrc.local-pre-omz


# maybe don't user TMPDIR as it might not be system-wise and will have undesired effect
#if [[ -n "$TMPDIR" ]]; then
#    ZSHRC_TMPDIR="$TMPDIR"
#elif command -v termux-setup-storage >/dev/null; then
    # probably should never really need this?
if command -v termux-setup-storage >/dev/null; then
    ZSHRC_TMPDIR="$PREFIX/tmp"
else
    ZSHRC_TMPDIR="/tmp"
fi


# should before init om-my-zsh (rbenv plugin)
check_cmd ruby && export PATH="$(ruby -e 'puts Gem.user_dir')/bin:$PATH"
check_cmd ruby && plugins+=(rbenv)

source $ZSH/oh-my-zsh.sh


# disable some annoying things...
unalias ss 2>/dev/null

# User configuration

#export PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# # Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
   export SYSTEMD_EDITOR='vim'
# else
#   export EDITOR='mvim'
#   export SYSTEMD_EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"



[[ -d "$HOME/go" ]] && {
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
}


setopt NO_BEEP

# for gpg pinentry
export GPG_TTY=$(tty)

# ssh with gpg
if_gpg_updatestartuptty() {
    ! is_win && check_cmd gpg-connect-agent
}
if_gpg_updatestartuptty && (gpg-connect-agent updatestartuptty /bye &) >/dev/null 2>/dev/null 
_screen_ssh_auth_path="$ZSHRC_TMPDIR/screen-ssh-auth-sockets/$USER"
_ssh_agent_gpg_socket_for_screen() {
    if [[ -n "$STY" ]]; then
        rm "$_screen_ssh_auth_path/gpg.$STY" 2> /dev/null
        ln -s "$SSH_AUTH_SOCK_GPG" "$_screen_ssh_auth_path/gpg.$STY"
        export SSH_AUTH_SOCK_GPG="$_screen_ssh_auth_path/gpg.$STY"
    fi
}
update_ssh_agent_gpg_socket() {
    if is_win && [[ -n "$SSH_AUTH_SOCK" ]]; then
        export SSH_AUTH_SOCK_GPG="$SSH_AUTH_SOCK"
    else
        check_cmd gpg || return
        #export SSH_AUTH_SOCK_GPG=$(gpgconf --list-dirs agent-ssh-socket)
        # Try to support very old gpg... CentOS 7...
        export SSH_AUTH_SOCK_GPG=$(gpgconf --list-dirs | awk -F: '/agent-ssh-socket/{print $2}')
        _ssh_agent_gpg_socket_for_screen
    fi
}
if [[ -n "$STY" ]]; then
    mkdir -p "$_screen_ssh_auth_path"
    chmod 700 "$_screen_ssh_auth_path"
fi
if [[ -n "$SSH_AUTH_SOCK_FORWARD" ]] && [[ -n "$STY" ]] && [[ "$SSH_AUTH_SOCK_FORWARD" != "$_screen_ssh_auth_path/forward.$STY" ]]; then
    rm "$_screen_ssh_auth_path/forward.$STY" 2> /dev/null
    ln -s "$SSH_AUTH_SOCK_FORWARD" "$_screen_ssh_auth_path/forward.$STY"
    export SSH_AUTH_SOCK_FORWARD="$_screen_ssh_auth_path/forward.$STY"
elif [[ -n "$SSH_AUTH_SOCK" ]]; then
    export SSH_AUTH_SOCK_FORWARD="$SSH_AUTH_SOCK"
fi
if [[ -z "$SSH_AUTH_SOCK_GPG" ]] || [[ ! -S "$(readlink -e "$SSH_AUTH_SOCK_GPG")" ]]; then
    update_ssh_agent_gpg_socket
elif [[ -n "$STY" ]] && [[ "$SSH_AUTH_SOCK_GPG" != "$_screen_ssh_auth_path/gpg.$STY" ]]; then
    _ssh_agent_gpg_socket_for_screen
fi
if [[ -n "$SSH_AUTH_SOCK_GPG" ]]; then
    export SSH_AUTH_SOCK="$SSH_AUTH_SOCK_GPG"
elif [[ -n "$SSH_AUTH_SOCK_FORWARD" ]]; then
    export SSH_AUTH_SOCK="$SSH_AUTH_SOCK_FORWARD"
fi
if [[ -n "$STY" ]]; then
    rm "$_screen_ssh_auth_path/$STY" 2> /dev/null
    ln -s "$SSH_AUTH_SOCK" "$_screen_ssh_auth_path/$STY"
    export SSH_AUTH_SOCK="$_screen_ssh_auth_path/$STY"
fi
switch_ssh_agent_forward() {
    [[ -z "$SSH_AUTH_SOCK_FORWARD" ]] && return
    if [[ -n "$STY" ]]; then
        rm "$_screen_ssh_auth_path/$STY" 2> /dev/null
        ln -s "$SSH_AUTH_SOCK_FORWARD" "$_screen_ssh_auth_path/$STY"
    else
        export SSH_AUTH_SOCK="$SSH_AUTH_SOCK_FORWARD"
    fi
}
switch_ssh_agent_gpg() {
    [[ -z "$SSH_AUTH_SOCK_GPG" ]] && return
    if [[ -n "$STY" ]]; then
        rm "$_screen_ssh_auth_path/$STY" 2> /dev/null
        ln -s "$SSH_AUTH_SOCK_GPG" "$_screen_ssh_auth_path/$STY"
    else
        export SSH_AUTH_SOCK="$SSH_AUTH_SOCK_GPG"
    fi
}
_screen_ssh_auth_sockets_cleanup() {
    if [[ -d "$_screen_ssh_auth_path" ]]; then
        local files=$(find "$_screen_ssh_auth_path" -mindepth 1 | grep -v "$(command screen -ls | awk -v ORS='\\|' '/[ \t]+[0-9]+\./{ print $1 }' | sed 's/..$//')")
        [[ -n "$files" ]] && echo $files | xargs rm
    fi
}


gpg() {
    if [[ "$*" == *"--just-send-key"* ]]; then
        command gpg "${@/--just-send-key/--send-key}"
    elif [[ "$*" == *"--send-key"* ]]; then
        echo "if you're trying to upload/update keys to keyservers,"
        echo "use the proper update script ~/upload-my-gpg-key.sh"
        echo "(https://gist.github.com/danny8376/59f92eb2cc871607edf0b9e60fcbcfd7)"
    else
        command gpg "$@"
    fi
}


export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'


screen() {
    export TERM_OUTSIDE_SCREEN="$TERM"
    command screen "$@"
    _screen_ssh_auth_sockets_cleanup
}

ssh() {
    if [[ $TERM = screen* ]]; then
        (
            if [[ -n $TERM_OUTSIDE_SCREEN ]]; then
                export TERM="$TERM_OUTSIDE_SCREEN"
            else
                export TERM=xterm # not good i guess?
            fi
            command ssh "$@"
        )
    else
        command ssh "$@"
    fi
}


try_update_gpgagenttty() {
    check_cmd gpg-connect-agent || return
    local commands2exec=( "${(@fA)3}" )
    local updatetty=false
    for command in "$commands2exec[@]"; do
        case "$command" in
            ssh*|mosh*|git*|sudo*) updatetty=true ;;
            # gpg should be already handled by GPG_TTY
        esac
    done
    if $updatetty; then
        gpg-connect-agent updatestartuptty /bye >/dev/null 2>/dev/null
    fi
}
if_gpg_updatestartuptty && preexec_functions+=try_update_gpgagenttty


append_path "$HOME/.rbenv/bin"
check_cmd rbenv && eval "$(rbenv init - zsh)"

append_path "$HOME/.crenv/bin"
check_cmd crenv && eval "$(crenv init - zsh)"

check_cmd volta "$HOME/.volta/bin/volta" && {
    export VOLTA_HOME=$HOME/.volta
    export PATH="$VOLTA_HOME/bin:$PATH"
}

# for maybe some machine specific things
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
