# -*- mode: shell-script -*-

export TZ=JST-9
#export LANG=ja_JP.eucJP
export LANG=ja_JP.UTF-8
export LC_MESSAGES=C
export LC_TIME=C
export MANPAGER='less -isRWXgj.3'

if [ -e ~/lib/ruby ]; then
   export RUBYLIB=~/lib/ruby
fi

# PROMPT='%B%n@%m[%?]%~%b%# '
# RPROMPT='%B%~%b'

if [ `hostname` = "iulius.hage.teria.com" ]; then
    export POSTGRES_HOME=/usr/local/pgsql
    export PGLIB=/usr/local/lib
    export PGDATA=$POSTGRES_HOME/data
    export PATH=$PATH:/sbin:/usr/sbin
    export CVSROOT=:pserver:localhost:/usr/home/cvsroot
    export REFE_DATA_DIR=/usr/local/share/refe
fi

if [ `hostname` = "curry.local" ]; then
    export PATH=$PATH:
fi

if [ `uname` = "Darwin" ]; then
    # PATHの頭に挿入する文字列
    mypath=$HOME/bin:$HOME/opt/bin:/usr/local/bin
    if [ -e /Applications/UpTeX.app/teTeX/bin ]; then
        mypath=$mypath:/Applications/UpTeX.app/teTeX/bin
    fi
    if [ -z `echo $PATH | grep "$mypath"` ]; then
     	export MANPATH=/opt/local/share/man:$MANPATH
    fi
    # screenなどで新たにシェルを起動するとき、システムが知らないパス(/opt/local/binなど)を後ろへ回してしまうため
    # それを阻止する。頭にmypathを挿入し、既にPATH存在するmypath (後回しにされたもの) を消し、:などを調整する
    export PATH=$mypath:/usr/local/bin:`echo $PATH|sed -e "s|$mypath||"|sed -e 's/::/:/'|sed -e 's/=:/=/'|sed -e 's/:$//'`
    unset mypath
fi

if [ -e ~/lib/tex ]; then
    export TEXINPUTS=.:~/lib/tex//:
fi

export OMAKEPATH=~/lib/makefile:/usr/local/lib/omake:.

if which rbenv > /dev/null; then eval "$(rbenv init --no-rehash - zsh)" ; fi
