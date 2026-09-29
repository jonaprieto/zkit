#!/usr/bin/env zsh
# zsh tests/run.zsh [FILE...]: runs each tests/test_*.zsh (or
# the given files) in a clean zsh with its own temp dir.
# Stops at the first failing file.

emulate -R zsh
root=${0:A:h:h}
files=("$@")
(( $#files )) || files=($root/tests/test_*.zsh(N))
for t in $files; do
  print -r -- "# ${t:t}"
  zsh -f $root/tests/lib.zsh $root ${t:A} || exit 1
done
