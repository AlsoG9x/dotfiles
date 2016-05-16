# this file goes to  ~/.oh-my-zsh/themes/alsotalhnan.zsh-theme
#
# vim:ft=zsh ts=2 sw=2 sts=2
#
# forked from agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts
CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''
# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
local bg fg
[[ -n $1 ]] && bg="%K{$1}" || bg="%k"
[[ -n $2 ]] && fg="%F{$2}" || fg="%f"
if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
else
echo -n "%{$bg%}%{$fg%} "
fi
CURRENT_BG=$1
[[ -n $3 ]] && echo -n $3
}
# End the prompt, closing any open segments
prompt_end() {
if [[ -n $CURRENT_BG ]]; then
echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
else
echo -n "%{%k%}"
fi
echo -n "%{%f%}"
CURRENT_BG=''
}
### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown
# Context: user@hostname (who am I and where am I)
prompt_context() {
local user=`whoami`
if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
prompt_segment blue black "%(!.%{%F{yellow}%}.)$user@%m" #was magenta black
fi
}
# Git: branch/detached head, dirty status
prompt_git() {
local ref dirty
if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
ZSH_THEME_GIT_PROMPT_DIRTY='±'
dirty=$(parse_git_dirty)
ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
if [[ -n $dirty ]]; then
prompt_segment yellow black
else
prompt_segment green black
fi
# echo -n "${ref/refs\/heads\//⭠ }$dirty"
# modified to remove branch symbol
echo -n "${ref/refs\/heads\//} $dirty"
fi
}
# Dir: current working directory
prompt_dir() {
prompt_segment yellow black '%C'
}
# Time: current time
prompt_time() {
prompt_segment cyan black '%D{%H:%M:%S}'
}
# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
[[ $RETVAL -eq 0 ]] && prompt_segment green black '✔'
[[ $RETVAL -ne 0 ]] && prompt_segment red black '✘'
[[ $UID -eq 0 ]] && prompt_segment yellow black '⚡'
[[ $(jobs -l | wc -l) -gt 0 ]] && prompt_segment white black '⚙'
}
## Main prompt
build_prompt() {
RETVAL=$?
prompt_time
prompt_status
prompt_context
prompt_dir
prompt_git
prompt_end
}
PROMPT='%{%f%b%k%}$(build_prompt) '
