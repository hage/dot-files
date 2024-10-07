# -*- mode:shell-script -*-

# if [ "$TERM_PROGRAM" = "iTerm.app" -a "$TMUX" = "" ]; then
#     eval `tset -s xterm-24bits`
# elif [ "$IN_SCREEN" = "1" -o "$TERM" = "screen" ]; then
#     eval `tset -s xterm-256color`
#     export IN_SCREEN=1
# elif [ "$TERMINAL_EMULATOR" = "PuTTY" ]; then
#     eval `tset -s xterm-256color`
# fi

export HOMEBREW_PREFIX="$(brew --prefix)"

if [ "$IN_LOGIN" = "true" ]; then
    unset IN_LOGIN
else
    [ -f /usr/games/fortune ] && fortune ~/doc/2ch-fortune
fi

export GUARD_GEM_SILENCE_DEPRECATIONS=1

case ${OSTYPE} in
    darwin*)
        fpath=(${HOMEBREW_PREFIX}/share/zsh/functions ${fpath})
        ;;
esac

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
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history

# pager
PAGER=/usr/bin/less; export PAGER
export LESS='-RMiXgj.3'
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

alias emacsclient='/Applications/Emacs.app/Contents/MacOS/bin-arm64-11/emacsclient'


# alias www='w3m -X'
# alias wwv='w3m -X -T text/html'
# alias wwb='w3m -B'
# alias run-help=man
# which jman > /dev/null && alias man='jman'
# alias less='w3m -X'
# alias jless='w3m -X'
# alias em='open -a emacs'
alias ebc='emacs -batch -f batch-byte-compile'
alias el='emacs -q --load ~/.emacs.d/n/init.el'
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
alias cdg='cd `git rev-parse --show-toplevel`'

# ~~ でproject rootのパスに置き換わる未完成
bindkey -s '~~' '$(git rev-parse --show-toplevel)\t'

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

if [ -d ${HOMEBREW_PREFIX}/opt/erlang/lib/erlang/man ]; then
    MANPATH=$MANPATH:${HOMEBREW_PREFIX}/opt/erlang/lib/erlang/man
fi

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
function tmux-select-emacs () {
    if [ $TMUX ] ; then
	tmux select-window -t 'Emacs'
    fi
}

function e () {
    emacsclient -a emacs -n $*
    tmux-select-emacs
}

function et () {
    emacsclient -e "(elscreen-find-file \"$*\")"
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
        cd "$EMACS_CWD"
}
alias cdd='cde;cdg;echo " -> `pwd`"'

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
    if [ `tmux lsp|wc -l` -ge 2 ]; then
        color_man $@
    else
        LESS="-L" tmux split-window -h "color_man $@"
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
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

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
# # cdr, add-zsh-hook を有効にする
# autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
# add-zsh-hook chpwd chpwd_recent_dirs

# # cdr の設定
# zstyle ':completion:*' recent-dirs-insert both
# zstyle ':chpwd:*' recent-dirs-max 500
# zstyle ':chpwd:*' recent-dirs-default true
# zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/shell/chpwd-recent-dirs"
# zstyle ':chpwd:*' recent-dirs-pushd true


################ peco
FZF_COMMAND=fzf

if which $FZF_COMMAND > /dev/null
then
    source <(fzf --zsh)

    ################ history
    function select-history() {
        BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
        CURSOR=$#BUFFER
        zle reset-prompt
    }
    zle -N select-history
    bindkey '^r' select-history

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

    export FZF_DEFAULT_OPTS='--height 40% --reverse -e --bind=ctrl-k:kill-line,ctrl-v:page-down,alt-v:page-up --color=dark,hl:202 --highlight-line --no-separator --pointer=">" --marker">"'
    export FZF_TMUX=1
    alias fzf="LANG=C RUNEWIDTH_EASTASIAN=1 $FZF_COMMAND"
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    ################ Docker
    # DP: docker kill DP のように使う
    alias -g DP='`docker ps -a | $FZF_COMMAND --header-lines=1 -m --prompt "Docker Processes: " | cut -d" " -f1`'
    alias -g DI='`docker images | $FZF_COMMAND --header-lines=1 -m --prompt "Docker Images: " | awk "{if (\\$1 == \"<none>\") {print \\$3} else {print \\$1 \":\" \\$2}}"`'

    alias docker-ip="docker inspect --format '{{ .NetworkSettings.IPAddress }}' DP"
fi

################ directory alias
export DIRECTRY_ALIAS_FILE=~/.directory_alias
[ -f $DIRECTRY_ALIAS_FILE ] && source $DIRECTRY_ALIAS_FILE

################ zplug
export ZPLUG_HOME="$HOMEBREW_PREFIX/opt/zplug"
source $ZPLUG_HOME/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'


# theme (https://github.com/sindresorhus/pure#zplug)　好みのスキーマをいれてくだされ。
zplug "mafredri/zsh-async"
# zplug "sindresorhus/pure"
# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zplug "zsh-users/zsh-syntax-highlighting"
# history関係
zplug "zsh-users/zsh-history-substring-search", as:plugin
# タイプ補完

# zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-autosuggestions", hook-load: "ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(auto_bundle_exec_accept_line $ZSH_AUTOSUGGEST_CLEAR_WIDGETS)"

zplug "zsh-users/zsh-completions", hook-load: "plugins=($PLUGINS zsh-completions)"
zplug "chrissicool/zsh-256color"
zplug "rhysd/zsh-bundle-exec"
zplug "hage/tmuxtabinfo.zsh", use:tmuxtabinfo.zsh, hook-load:"tmuxtabinfo"
zplug "Tarrasch/zsh-autoenv"

# notify
zplug "marzocchi/zsh-notify"
zstyle ':notify:*' command-complete-timeout 10
zstyle ':notify:*' notifier ${HOMEBREW_PREFIX}/bin/terminal-notifier

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

autoload -U colors; colors      # ${fg[...]} や $reset_color をロード
setopt prompt_subst             # プロンプトが表示されるたびにプロンプト文字列を評価、置換する

prompt_pwd='%{[32m%}%~%b%{[m%}'
PROMPT='%{[32m%}${WINDOW:+"$WINDOW:"}%n@%B%m%b(%?)%{[m%}%B%#%b '


### 以下自前でRPROMPTを2行に分けたような感じにしていたときの名残
function unescapesequence() {
    echo "$1" | sed -e 's/%{//g;s/%}//g;s/[^]*//g;'
}
function right_aligned_print() {
    str=$1
    len=`unescapesequence $str | wc -m`
    padwidth=$(($COLUMNS - $len))
    print -P ${(r:$padwidth:: :)}$str
}
# precmd () {
#     wd=`echo $PWD | sed -e "s%^$HOME%~%"`
#     right_aligned_print "[%{[32m%}$wd%{[m%}]"
# }
### 名残以上

function git_show_branch_for_prompt() {
    branch=`git branch --show-current 2>/dev/null`
    if [ "$?" = "0" ] ; then
        branch="[$branch]"
    else
        branch=''
    fi
    echo $branch
}
export RPROMPT="$(git_show_branch_for_prompt)[%{${fg[green]}%}%~%{${reset_color}%}]"

export PATH="${HOMEBREW_PREFIX}/opt/imagemagick@6/bin:$PATH"

autoload -U compinit
compinit



# export PATH="${HOMEBREW_PREFIX}/bin:$PATH" # .zshenvで設定済み
export LDFLAGS="-L${HOMEBREW_PREFIX}/lib"
export CPPFLAGS="-I${HOMEBREW_PREFIX}/include"
export PKG_CONFIG_PATH="${HOMEBREW_PREFIX}/pkgconfig"

# # ncurses
# export PATH="${HOMEBREW_PREFIX}/opt/ncurses/bin:$PATH"
# export LDFLAGS="-L${HOMEBREW_PREFIX}/opt/ncurses/lib"
# export CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/ncurses/include"
# export PKG_CONFIG_PATH="${HOMEBREW_PREFIX}/opt/ncurses/lib/pkgconfig"

# IEx
export ERL_AFLAGS="-kernel shell_history enabled"

# added by travis gem
[ -f /Users/tura/.travis/travis.sh ] && source /Users/tura/.travis/travis.sh


# icu4c
# if [ -e ${HOMEBREW_PREFIX}/opt/icu4c/bin ]; then
#     export PATH="${HOMEBREW_PREFIX}/opt/icu4c/bin:$PATH"
#     export PATH="${HOMEBREW_PREFIX}/opt/icu4c/sbin:$PATH"
#     export LDFLAGS="-L${HOMEBREW_PREFIX}/opt/icu4c/lib"
#     export CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/icu4c/include"
#     export PKG_CONFIG_PATH="${HOMEBREW_PREFIX}/opt/icu4c/lib/pkgconfig"
# fi

export EDITOR='cot -w'
eval "$(direnv hook zsh)"
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

# # openssl
# export PATH="${HOMEBREW_PREFIX}/opt/openssl@1.1/bin:$PATH"
# export LDFLAGS="-L${HOMEBREW_PREFIX}/opt/openssl@1.1/lib"
# export CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/openssl@1.1/include"
# export PKG_CONFIG_PATH="${HOMEBREW_PREFIX}/opt/openssl@1.1/lib/pkgconfig"
