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
RPROMPT='%{[32m%}%~%b%{[m%}'
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

# コマンド特有の補完
#  Hosts to use for completion (see later zstyle)
hosts=(localhost `hostname` scipio.hage.teria.com \
    master.teria.com club.sp-network.co.jp hage@mizu.nurs.or.jp \
    catalog.you-group.com 211.4.228.10 neon.excite.co.jp
    flat4.unixmagic.net augustus.hage.teria.com neon.excite.co.jp \
    iulius.hage.teria.com ssh promo01.tailback.co.jp \
    catalog2.webpass.jp mitaka2.mitaka.ne.jp gizmobies.co.jp\
    m4p4-freebsd.hage.teria.com airnavi.local)
cdpath=(~ ~/project)

autoload -U compinit
compinit
# autoload predict-on
# predict-on

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
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
if test -x /usr/local/bin/lv; then
    PAGER=/usr/local/bin/lv; export PAGER
    LV="-c -E'$EDITOR +%d'"; export LV
else
    PAGER=/usr/bin/less; export PAGER
    export LESS='-X'
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
alias cleanelc='rm ~/.emacs.elc; rm `find ~/.emacs -name "*.elc"`'

alias sshhpcat='ssh -C -R 12321:127.0.0.1:2401 hpcat.you-group.com'
alias sshbinmlm='ssh -C -R 12321:127.0.0.1:2401 ura@211.4.228.10'
alias sshgpnk='ssh -C -R 12321:127.0.0.1:2401 flat4.unixmagic.net'
alias sshteria='ssh -C -R 12321:127.0.0.1:2401 master.teria.com'
alias sshdrop='env TERM=xterm-color ssh -C drop@neon.excite.co.jp'
alias sshfitness='env TERM=xterm-color ssh -C fitness@neon.excite.co.jp'
alias sshkobukuro='env TERM=xterm-color ssh -C teamkobukuro@neon.excite.co.jp'

alias errhpcat='tail -n 500 -F ~/project/hpcat/log/error.log |eruby_logdump /home/tura/project/hpcat/'
alias debughpcat='tail -F ~/project/hpcat/debug.log'

alias errbinmlm='tail -n 500 -F ~/project/binmlm/log/error.log |eruby_logdump /home/tura/project/binmlm/'
alias debugbinmlm='tail -F ~/project/binmlm/debug.log'

alias pgais='psql83 -U mt2004002 1mindiag'
# alias svn='LC_MESSAGES=ja_JP.eucJP svn'


alias e='emacsclient -t'
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

export LSCOLORS=dxfxcxdxbxegedabagacad

export GIT_PAGER='less -RF'
export LANG=ja_JP.UTF-8

# homebrewを優先
export PATH=~/bin:/usr/local/bin:$PATH

# rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# auto-fu.zsh
#   cd ~/bin && git clone https://github.com/hchbaw/auto-fu.zsh.git
autofuzsh=$HOME/bin/auto-fu.zsh/auto-fu.zsh
if [[ -s $autofuzsh ]] ; then
    source $autofuzsh

    zstyle ':auto-fu:highlight' input bold
    zstyle ':auto-fu:highlight' completion fg=black,bold
    zstyle ':auto-fu:var' postdisplay $'\n-azfu-'

    zle-line-init () { auto-fu-init; }
    zle -N zle-line-init
# auto-fuをカスタマイズする。
## Enterを押したときは自動補完された部分を利用しない。
    afu+cancel-and-accept-line() {
        ((afu_in_p == 1)) && { afu_in_p=0; BUFFER="$buffer_cur" }
        zle afu+accept-line
    }
    zle -N afu+cancel-and-accept-line
    bindkey -M afu "^M" afu+cancel-and-accept-line
fi

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"

cd ~
