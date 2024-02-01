set -Ux FZF_DEFAULT_OPTS "--height=80% --exact --reverse --border rounded --inline-info --prompt='🔭 ' --pointer='👉' --marker=' ' --ansi --color='16,bg+:-1,gutter:-1,prompt:5,pointer:5,marker:6,border:4,label:4,header:italic' --preview 'file --mime-type {} | bat --color=always {}' --preview-window='right,60%:hidden' --bind \?:toggle-preview --bind pgup:preview-page-up --bind pgdn:preview-page-down"
# set -Ux FZF_DEFAULT_OPTS "--exact --reverse --border rounded --inline-info --ansi --pointer='' --marker='' --color='16,bg+:-1,gutter:-1,prompt:5,pointer:5,marker:6,border:4,label:4,header:italic'"

# --pointer=' ' \
# --marker=' ' \
#
set -Ux FZF_TMUX_OPTS "-p 55%,60%"

set -Ux FZF_CTRL_R_OPTS "--border-label=' history ' \
--prompt='  '"
