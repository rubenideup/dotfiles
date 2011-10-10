#!/bin/bash

# start to watch local repositories
if [ $(which git-dude 2>/dev/null) ]; then
  git dude .git-dude/
fi
