ln -s ~/.dotfiles/vimrc ~/.vimrc
ln -s ~/.dotfiles/vim ~/.vim

cd ~/.dotfiles
git submodule init
git submodule update
