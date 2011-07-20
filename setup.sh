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
  mksymlink ~/.vim-keymaps
  mksymlink ~/.vim-au
  mksymlink ~/.bashrc
  mksymlink ~/.bash_aliases

  if [ ! -d ~/.vim/swp ]; then
    mkdir ~/.vim/swp
  fi
}

install_helper_scripts() {
  echo "Installing helper scripts ..."

  # install ksshaskpass to remember SSH keys in KDE desktop
  if [ -d ~/.kde -a ! -L ~/.kde/Autostart/ssh-add.sh ]; then
    ln -s ~/.dotfiles/scripts/ssh-add.sh ~/.kde/Autostart/ssh-add.sh
  fi
}

install
echo "Installing bundles..."
ruby `pwd`/vim/bin/vim-update-bundles.rb
#install_helper_scripts

echo "Done."
