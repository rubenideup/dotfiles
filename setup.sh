#!/bin/sh

# this script maps my configuration files in a fresh system.
# does not delete any configuration file or directory, if any exists
# the install process simply rename it to *.old

# you can safetely run this install script many times in order to update
# git submodules and check symlinks

install_helper_scripts() {
  echo "Installing helper scripts ..."

  # install ksshaskpass to remember SSH keys in KDE desktop
  if [ -d ~/.kde -a ! -L ~/.kde/Autostart/ssh-add.sh ]; then
    ln -s ~/.dotfiles/scripts/ssh-add.sh ~/.kde/Autostart/ssh-add.sh
  fi
}

echo "Saving old files ..."
for file in ~/.vimrc ~/.vim ~/.vimrc-keymaps ~/.vimrc-au ~/.bashrc ~/.bash_aliases; do
  if [ ! -L $file ]; then
    mv $file "$file.`date +$s`.old"
  else
    rm -f $file
  fi
done

echo "Linking dot files ..."
for file in vim vimrc vimrc-keymaps vimrc-au bashrc bash_aliases; do
  ln -s "`pwd`/$file" "$HOME/.$file"
done

echo "Installing bundles..."
ruby `pwd`/vim/bin/vim-update-bundles.rb
#install_helper_scripts

echo "Done."
