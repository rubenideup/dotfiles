all:
	ln -s ~/.dotfiles/vimrc ~/.vimrc
	ln -s ~/.dotfiles/vim ~/.vim
	ln -s ~/.dofiles/bash_aliases ~/.bash_aliases
	ln -s ~/.dofiles/bashrc ~/.bashrc


init-submodules:
	cd ~/.dotfiles
	git submodule init
	git submodule update
