# -*- mode: shell-script -*-

#   typeset
#    -U 重複パスを登録しない
#    -x exportも同時に行う
#    -T 環境変数へ紐付け
#
#   path=xxxx(N-/)
#     (N-/): 存在しないディレクトリは登録しない
#     パス(...): ...という条件にマッチするパスのみ残す
#        N: NULL_GLOBオプションを設定。
#           globがマッチしなかったり存在しないパスを無視する
#        -: シンボリックリンク先のパスを評価
#        /: ディレクトリのみ残す
#        .: 通常のファイルのみ残す
#    cf. http://yonchu.hatenablog.com/entry/20120415/1334506855
typeset -x -T OMAKEPATH omakepath
typeset -U path cdpath fpath manpath omakepath

# PATH
if [ `uname` = "Darwin" ]; then
    path=(/usr/local/sbin(N-/) ~/bin(N-/) ~/.rbenv/shims(N-/) ~/opt//bin(N-/) /usr/local/bin(N-/) /opt/homebrew/sbin(N-/) /opt/homebrew/bin(N-/) /usr/local/texlive/2024basic/bin/universal-darwin(N-/) ${path})
    manpath=(/usr/local/share/man(N-/) /usr/local/opt/erlang/lib/erlang/man(N-/) /Library/Developer/CommandLineTools/SDKs/MacOSX10.14.sdk/usr/share/man(N-/) /Library/Developer/CommandLineTools/usr/share/man(N-/) ${manpath})
    export MANPATH
fi

# 一般的なシェル変数の設定
export TZ=JST-9
export LANG=ja_JP.UTF-8
export LC_MESSAGES=C
export LC_TIME=C

if [ -e ~/lib/ruby ]; then export RUBYLIB=~/lib/ruby ; fi
if [ -e ~/lib/tex ]; then export TEXINPUTS=.:~/lib/tex//: ; fi
if type rbenv > /dev/null; then eval "$(rbenv init --no-rehash - zsh)" ; fi
if type omake > /dev/null 2>&1; then omakepath=(~/lib/makefile(N-/) /usr/local/lib/omake(N-/) .) ; fi
