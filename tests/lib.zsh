# Test helpers, then sources the test file $2 (zkit root: $1).
# Each test file gets a fresh temp dir $T.

emulate -R zsh
setopt extendedglob
zmodload -F zsh/stat b:zstat
zmodload zsh/datetime

ZKIT=$1
T=$(mktemp -d)
T=${T:A}
trap 'chmod -R u+rwx $T 2>/dev/null; command rm -rf $T' EXIT

export XDG_CACHE_HOME=$T/cache
export LC_COLLATE=C
if [[ ${LC_ALL:-${LC_CTYPE:-$LANG}} != *UTF-8* ]]; then
  export LC_ALL=C.UTF-8
fi

# git fixtures must not see the runner's or developer's config
# (signing, default branch, identity)
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t

source $ZKIT/zkit.zsh

# run CMD...: run in this shell, so _zkit_paths survives.
# Sets RC, OUT and ERR.
run() {
  "$@" >$T/.out 2>$T/.err
  RC=$?
  OUT=$(<$T/.out)
  ERR=$(<$T/.err)
}

# Columns of zls rows, fixed width: number 3, size 6, age 4,
# then the name.
nums() {
  local l
  for l in "${(@f)1}"; do print -r -- ${${l[1,3]}## #}; done
}
sizes() {
  local l
  for l in "${(@f)1}"; do print -r -- ${${l[5,10]}## #}; done
}
ages() {
  local l
  for l in "${(@f)1}"; do print -r -- ${${l[12,15]}## #}; done
}
names() {
  local l
  for l in "${(@f)1}"; do print -r -- ${l[18,-1]}; done
}

# ago SECONDS FILE...: set the mtime SECONDS in the past
# (negative: in the future), through the portable touch -t.
ago() {
  local ts s=$1
  shift
  strftime -s ts %Y%m%d%H%M.%S $(( EPOCHSECONDS - s ))
  touch -t $ts "$@"
}
Y=31536000

# until_ok SECONDS CMD...: retry CMD every 0.2s until it
# succeeds or SECONDS pass. Returns CMD's last status.
until_ok() {
  local end=$(( EPOCHREALTIME + $1 ))
  shift
  until "$@"; do
    (( EPOCHREALTIME < end )) || return 1
    sleep 0.2
  done
}

# check LABEL ACTUAL EXPECTED
check() {
  if [[ $2 == $3 ]]; then
    print -r -- "ok   $1"
    return
  fi
  print -r -- "FAIL $1"
  print -r -- "  expected: ${(q+)3}"
  print -r -- "  actual:   ${(q+)2}"
  exit 1
}

source $2
