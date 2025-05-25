#!/bin/bash

dest=$HOME/.gitconfig

if [ ! -e $dest ]; then
  ln -s "$HOME/dotfiles/git/.gitconfig" $dest
fi
