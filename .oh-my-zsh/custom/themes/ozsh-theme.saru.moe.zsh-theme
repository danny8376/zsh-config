# modified from theme " candy "

PROMPT=$'%{$fg_bold[green]%}%n@%m %{$fg[blue]%}%D{[%I:%M:%S]} %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $(git_prompt_info) $fg[magenta]<$(ruby_prompt_info)>%{$reset_color%}\
%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

function () {
    local owner
    case "$USER" in
        danny)  owner="Σ";;
        root)   owner="√";; # likely will never see?
        *)      owner="%n@";;
    esac

    # broken on msys2/mingw and busybox, will fallback to normal tab title
    case "$(ps -o comm= -p "$PPID" 2>/dev/null)" in
        sshd|*/sshd|mosh*)
            ZSH_THEME_TERM_TAB_TITLE_IDLE="%5>…>%m%>>:%9<..<%~%<<";;
        *)
            ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<";;
    esac

    ZSH_THEME_TERM_TITLE_IDLE="${owner}%m:%~"
}
