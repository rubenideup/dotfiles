alias ll='ls -l'
alias la='ls -la'

if which trash &> /dev/null; then
  alias rm='trash'
else
  echo "Your rm's may harm you. Install trash package: apt-get install trash"
fi

alias cd..='cd ..'
alias wspotify='wine ~/.wine/drive_c/Archivos\ de\ programa/Spotify/spotify.exe'

alias gz="tar cvzf"
alias ugz="tar xvzf"

alias bz="tar cvjf"
alias ubz="tar xvjf"

# resume scp downloads 
alias rscp="rsync --partial --progress --rsh=ssh"

# storage SSH private keys in memory
alias ssh-remember="find ~/.ssh -name "id_?sa" -exec ssh-add {} \;"
