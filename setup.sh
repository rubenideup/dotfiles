#!/bin/sh

# this script maps my configuration files in a fresh system.
# does not delete any configuration file or directory, if any exists
# the install process simply rename it to *.old

# you can safetely run this install script many times in order to update
# git submodules and check symlinks

install_helper_scripts() {
  echo "Installing helper scripts ..."

  # install autostart scripts
  if [ -d ~/.kde -a ! -L ~/.kde/Autostart/bootstrap.sh ]; then
    ln -s ~/.dotfiles/scripts/bootstrap.sh ~/.kde/Autostart/bootstrap.sh
  fi
}

echo "Saving old files ..."
for file in ~/.vimrc ~/.vim ~/.vimrc-keymaps ~/.vimrc-au ~/.bashrc ~/.bash_aliases; do
  if [ ! -L $file ]; then
    mv $file "$file.`date +%s`.old"
  else
    rm -f $file
  fi
done

echo "Linking dot files ..."
for file in vim vimrc vimrc-keymaps vimrc-au bashrc bash_aliases; do
  ln -s "`pwd`/$file" "$HOME/.$file"
done

echo "Installing bundles..."
if [ ! $(wich ruby 2>/dev/null) ]; then
  echo "ERROR: ruby is not installed. You have to install ruby and ruby-dev packages!"
else
  ruby `pwd`/vim/bin/vim-update-bundles.rb
fi

install_helper_scripts


echo "Done."
