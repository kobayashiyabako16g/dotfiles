# タブ補完
autoload -U compinit
compinit

# ヒストリの設定
export HISTSIZE=1000
export SAVEHIST=1000

# 直前のコマンドの重複を削除
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# cd-<tab>で以前移動したディレクトリを表示
setopt auto_pushd

# historyに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks
