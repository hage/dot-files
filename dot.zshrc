# -*- mode:shell-script -*-
if [ "$IN_SCREEN" = "1" -o "$TERM" = "screen" ]; then
    eval `tset -s xterm-256color`
    export IN_SCREEN=1
elif [ "$TERMINAL_EMULATOR" = "PuTTY" ]; then
    eval `tset -s xterm-256color`
fi

if [ "$IN_LOGIN" = "true" ]; then
    unset IN_LOGIN
else
    [ -f /usr/games/fortune ] && fortune ~/doc/2ch-fortune
fi

export GUARD_GEM_SILENCE_DEPRECATIONS=1


################ gitのブランチ名をコマンドラインに表示
# ${fg[...]} や $reset_color をロード
autoload -U colors; colors

function rprompt-git-current-branch {
        local name st color

        if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
                return
        fi
        name=$(basename "`git symbolic-ref HEAD 2> /dev/null`")
        if [[ -z $name ]]; then
                return
        fi
        st=`git status 2> /dev/null`
        if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
                color=${fg[green]}
        elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
                color=${fg[yellow]}
        elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
                color=${fg_bold[red]}
        else
                color=${fg[red]}
        fi

        # %{...%} は囲まれた文字列がエスケープシーケンスであることを明示する
        # これをしないと右プロンプトの位置がずれる
        echo "%{$color%}$name%{$reset_color%} "
}

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

# RPROMPT='[`rprompt-git-current-branch`%~]'
################ gitのブランチ名をコマンドラインに表示 ここまで


umask 022
setopt NOCLOBBER
setopt pushd_ignore_dups
setopt always_last_prompt       #
setopt auto_remove_slash        # remove tail '/' of completed dirname
setopt auto_pushd
setopt ALWAYS_TO_END
setopt extended_glob
setopt nolistbeep        # 補完表示時にビープ音を鳴らさない
setopt no_beep
unsetopt promptcr
limit coredumpsize 0
setopt prompt_subst
PROMPT='%{[32m%}${WINDOW:+"$WINDOW:"}%n@%B%m%b(%?)%{[m%}%B%#%b '
RPROMPT='[`rprompt-git-current-branch`%{[32m%}%~%b%{[m%}]'
WORDCHARS=''

if [ $EMACS ]; then
    precmd() {
    }
elif [ "$TERM" = "xterm-screen"j ]; then
    precmd() {
        TITLE=`print -P $USER@%M on tty%l: %~`
        echo -n "\e]2;\a\e]2;$TITLE\a"
    }
    function title() {
        echo -n "\ek$*\e\\"
    }
else
    precmd() {
        TITLE=`print -P $USER@%M on tty%l: %~`
        echo -n "\e]0;$TITLE\a"
    }
fi

# if [ $DISPLAY ]; then
#     xset +fp /usr/X11R6/lib/X11/fonts/local
# fi

if [ $MLTERM ]; then
    export BACKGROUND_BRITNESS=dark
fi

# 履歴をファイルに保存する
HISTFILE=$HOME/.zsh-history
# メモリ内の履歴の数
HISTSIZE=100000
# 保存される履歴の数
SAVEHIST=100000
# 履歴ファイルに時刻を記録
setopt extended_history
# 履歴の一覧を出力
function history-all { history -E 1 }
setopt histignorealldups
# すべてのzshプロセスで履歴を共有
setopt share_history
# スペースで始めるとヒストリに登録しない
setopt hist_ignore_space

# コマンド特有の補完
#  Hosts to use for completion (see later zstyle)
cdpath=(~ ~/project)

autoload -U compinit
compinit

# a-f[TAB] -> auto-fu  see http://gihyo.jp/dev/serial/01/zsh-book/0005
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'

zstyle ':completion:*:default' menu select=1
# command for process lists, the local web server details and host completion
zstyle ':completion:*:processes' command 'ps -o pid,s,nice,stime,args'
#zstyle ':completion:*:urls' local 'www' '/var/www/htdocs' 'public_html'
zstyle '*' hosts $hosts

# Ctrl + P/N で履歴検索 tcsh風味
bindkey -e
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# pager
PAGER=/usr/bin/less; export PAGER
export LESS='-FRMiXgj.3'
export MANPAGER='less -LisRWXgj.3'
# ソース表示に色づけ
# brew install source-highlight をすること
if which source-highlight > /dev/null ; then
    export LESSOPEN='| ~/bin/src-hilite-lesspipe-256.sh %s'
fi




# alias
alias ls='ls -GwF'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'


# alias www='w3m -X'
# alias wwv='w3m -X -T text/html'
# alias wwb='w3m -B'
# alias run-help=man
# which jman > /dev/null && alias man='jman'
# alias less='w3m -X'
# alias jless='w3m -X'
# alias em='open -a emacs'
alias ebc='emacs -batch -f batch-byte-compile'
alias -g L='|less'
alias -g G='|grep'
alias gd='dirs -v; echo -n "select number: "; read newdir; cd +"$newdir"'
alias sjis2euc='nkf -SXZeLu'
alias cleanelc='rm `find ~/.emacs.d -name "*.elc"`'
alias bx='bundle exec'
alias du1="du -hd1"
alias ql='qlmanage -p "$@" >& /dev/null'
alias rcreload='source ~/.zshrc'
alias wgett='wget --content-disposition'

function mkdirr {
    mkdir -p $*
    cd $*
}


# ee () {emacs $* &}
# if [ "$IN_SCREEN" = "1" ] ; then
#     alias e='screen -t "emacs `pwd`" env TERM=xterm-screen emacs -nw'
# else
#     alias e='emacs -nw'
# fi

link_dropbox_dot_files_command=~/Dropbox/sync/bin/link-dropbox-dot-files
alias update-sync-link="chmod 755 $link_dropbox_dot_files_command && $link_dropbox_dot_files_command"

# jman は環境変数 MANPATH 以下の全マニュアルページより補完
# jman <数字> だとマニュアルの section <数字> から補完
compdef _man jman

if [ "$TERM" = "emacs" ]; then
    stty onocr
    unsetopt promptcr
fi

# 補完候補一覧時に色づけ
LS_COLORS='no=00:fi=00:di=00;33:ln=01;35:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:'
export LS_COLORS
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

export LSCOLORS=dxfxcxdxgxegedabagacad

export LANG=ja_JP.UTF-8

function tmux-remake-socket () {
    if [ ! $TMUX ]; then
        return
    fi
    tmux_socket_file=`echo $TMUX|awk -F, '{print $1}'`
    if [ ! -S $tmux_socket_file ]; then
        mkdir -m700 `dirname $tmux_socket_file` 2> /dev/null
        killall -SIGUSR1 tmux
    else
        echo tmux unix domain socket exists! nothing to do.
    fi
    unset tmux_socket_file
}

#### Emacs functions
tmux-select-emacs () {
    if [ $TMUX ] ; then
	tmux select-window -t 'Emacs'
    fi
}

e () {
    emacsclient -a emacs -n $*
    tmux-select-emacs
}

alias ee='cd ~/.emacs.d && cask update && emacs'

## Invoke the ``dired'' of current working directory in Emacs buffer.
function eff () {
    if [ $1 ]; then
	dir="${1:A}/"
    else
	dir="$PWD/"
    fi
    tmux-select-emacs
    emacsclient -ne "(helm-find-files-1 \"$dir\")"
}

## Chdir to the ``default-directory'' of currently opened in Emacs buffer.
function cde () {
        EMACS_CWD=`emacsclient -e "(return-current-working-directory-to-shell)" | sed 's/^"\(.*\)"$/\1/'`
        echo "chdir to $EMACS_CWD"
        cd "$EMACS_CWD"
}

################################################################
# auto-fu.zsh
#   cd ~/bin && git clone https://github.com/hchbaw/auto-fu.zsh.git
# autofuzsh=$HOME/bin/auto-fu.zsh/auto-fu.zsh
# if [[ -s $autofuzsh ]] ; then
#     source $autofuzsh

#     zstyle ':completion:*' completer _oldlist _complete
#     zstyle ':auto-fu:highlight' input bold
#     zstyle ':auto-fu:highlight' completion fg=black,bold
#     # zstyle ':auto-fu:var' postdisplay $'\n-azfu-'
#     zstyle ':auto-fu:var' postdisplay $'' # -azfu-と表示させない

#     zle-line-init () { auto-fu-init; }
#     zle -N zle-line-init
# # auto-fuをカスタマイズする。
# ## Enterを押したときは自動補完された部分を利用しない。
#     afu+cancel-and-accept-line() {
#         ((afu_in_p == 1)) && { afu_in_p=0; BUFFER="$buffer_cur" }
#         zle afu+accept-line
#     }
#     zle -N afu+cancel-and-accept-line
#     bindkey -M afu "^M" afu+cancel-and-accept-line
# fi

if which ng > /dev/null; then export EDITOR=ng ; fi

# man for tmux
# tmux環境下にあるときにmanを表示させると画面を分割して表示する
function man_tmux() {
    if [ $# -le 1 ]; then
        tmux split-window -h "color_man $@"
    else
        color_man $@
    fi
}
if [ "$TMUX" != "" ]; then
    alias man=man_tmux
fi

if [ -r ~/.homebrew_github_api_token ]
then
    source ~/.homebrew_github_api_token
fi

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)" ; fi
# bundle exec を不要に http://qiita.com/ymmtmdk/items/374d5319e8d5c9ab2ff4
# export RUBYGEMS_GEMDEPS=-

stty -ixon

# docker
alias d=docker
alias dm=docker-machine
alias doc=docker-compose
function de() {
    eval "$(docker-machine env 2> /dev/null)"
}
de

alias v=vagrant

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

function indent2(){ a='(progn (let ((buf (generate-new-buffer "a"))) (with-current-buffer buf (condition-case nil (let (l) (while (setq l (read-string "")) (insert l "\n"))) (error nil))) (set-buffer buf))(';b='-mode)(indent-region (point-min)(point-max))(princ (buffer-string)))'; emacs -batch -l ~/.emacs.d/init.el -eval "$a$1$b"; }

################ cdr の設定
# cdr, add-zsh-hook を有効にする
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# cdr の設定
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/shell/chpwd-recent-dirs"
zstyle ':chpwd:*' recent-dirs-pushd true


################ peco
FZF_COMMAND=fzf-tmux

if which $FZF_COMMAND > /dev/null
then
    ################ search a destination from cdr list
    function fzf-get-destination-from-cdr() {
        cdr -l | \
            sed -e 's/^[[:digit:]]*[[:blank:]]*//' | \
            $FZF_COMMAND --query "$LBUFFER"
    }

    ### search a destination from cdr list and cd the destination
    function fzf-cdr() {
        local destination="$(fzf-get-destination-from-cdr)"
        if [ -n "$destination" ]; then
            BUFFER="cd $destination"
            zle accept-line
        else
            zle reset-prompt
        fi
    }
    zle -N fzf-cdr
    bindkey '^x' fzf-cdr

    export FZF_DEFAULT_OPTS='--height 40% --reverse -e --bind=ctrl-k:kill-line,ctrl-v:page-down,alt-v:page-up --color=dark,hl:202'
    export FZF_TMUX=1
    alias fzf=$FZF_COMMAND
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    ################ Docker
    # DP: docker kill DP のように使う
    alias -g DP='`docker ps -a | $FZF_COMMAND --header-lines=1 -m --prompt "Docker Processes: " | cut -d" " -f1`'
    alias -g DI='`docker images | $FZF_COMMAND --header-lines=1 -m --prompt "Docker Images: " | awk "{print \\$1 \":\" \\$2}"`'

    alias docker-ip="docker inspect --format '{{ .NetworkSettings.IPAddress }}' DP"
fi


################ zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'


# theme (https://github.com/sindresorhus/pure#zplug)　好みのスキーマをいれてくだされ。
zplug "mafredri/zsh-async"
# zplug "sindresorhus/pure"
# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zplug "zsh-users/zsh-syntax-highlighting"
# history関係
zplug "zsh-users/zsh-history-substring-search"
# タイプ補完
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"
zplug "rhysd/zsh-bundle-exec"

# notify
zplug "marzocchi/zsh-notify"
zstyle ':notify:*' command-complete-timeout 10
zstyle ':notify:*' notifier /usr/local/bin/terminal-notifier

# cd
zplug "changyuheng/zsh-interactive-cd"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
# Then, source plugins and add commands to $PATH
zplug load

################ zplug で読み込んだものの設定
# zsh-autosuggestions がゴミを残すようになったのでその対策
# https://qiita.com/__hage/items/dbdf2c9d28514fc85f37
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(auto_bundle_exec_accept_line $ZSH_AUTOSUGGEST_CLEAR_WIDGETS)
echo $ZSH_AUTOSUGGEST_CLEAR_WIDGETS

export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
