#!/bin/bash

# start to watch local repositories
if [ $(which git-dude 2>/dev/null) ]; then
  git dude .git-dude/
fi

# wrapper to handle SSH keys in KDE
if [ $(which ksshaskpass 2>/dev/null) ]; then
  export SSH_ASKPASS=/usr/bin/ksshaskpass
  ssh-add </dev/null
fi
