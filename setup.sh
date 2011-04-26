#!/bin/sh

# this script maps my configuration files in a fresh system.
# does not delete any configuration file or directory, if any exists 
# the install process simply rename it to *.old

# you can safetely run this install script many times in order to update
# git submodules and check symlinks 

mksymlink() {
  BASE=$(basename "$1")

  if [ ! -L "$1" ]; then
    mv ~/.dotfiles/$BASE $1.old 
    ln -s ~/.dotfiles/$BASE $1
  fi
}

install() {
  echo "Checking symlinks ..."
  mksymlink ~/.vimrc
  mksymlink ~/.vim
  mksymlink ~/.bashrc
  mksymlink ~/.bash_aliases

  mkdir ~/.vim/swp
}

update_submodules() {
  echo "Updating submodules ..."
  cd ~/.dotfiles
  git submodule init
  git submodule update
}

install
update_submodules

echo "Done."
