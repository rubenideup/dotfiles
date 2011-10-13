alias ll='ls -l'
alias la='ls -la'

if which trash &> /dev/null; then
  alias rm='trash'
else
  echo "Your rm's may harm you. Install trash package: apt-get install trash-cli"
fi

alias cd..='cd ..'
alias gti="git"
alias wspotify='wine ~/.wine/drive_c/Archivos\ de\ programa/Spotify/spotify.exe'

alias gz="tar cvzf"
alias ugz="tar xvzf"

alias bz="tar cvjf"
alias ubz="tar xvjf"

# resume scp downloads 
alias rscp="rsync --partial --progress --rsh=ssh"

# restart plasma
alias kplasma="kbuildsycoca4 && kquitapp plasma-desktop && kstart plasma-desktop &> /dev/null"

# mac pbcopy and pbpaste utilities
alias pbcopy="xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"

# tail php error logs
alias phplog="tail -f /tmp/php_errors.log"
alias sf=app/console
