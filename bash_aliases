alias ll='ls -l'
alias la='ls -la'

if which trash &> /dev/null; then
  alias rm='trash'
else
  echo "Your rm's may harm you. Install trash package: apt-get install trash"
fi

alias cd..='cd ..'
alias wspotify='wine ~/.wine/drive_c/Archivos\ de\ programa/Spotify/spotify.exe'
