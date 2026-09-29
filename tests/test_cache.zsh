# Size cache: reuse, mtime and age invalidation, the ~ … ?
# marks, background refresh, -r, and a hostile cache file.

cache=$XDG_CACHE_HOME/zkit/du
mkdir -p $T/c/x
cd $T/c
head -c 200000 /dev/zero > x/f
ago $(( 2 * Y )) x

# setc KB MEASURED STARTED: cache line for folder x, with x's
# current mtime
setc() {
  local -a f=($PWD/x $1 $(zstat +mtime x) $2 $3)
  mkdir -p ${cache:h}
  print -r -- ${(pj:\t:)f} >| $cache
}
# cached KB for x, and what du says
cached() { grep "^$PWD/x"$'\t' $cache | cut -f2 }
real()   { print -r -- ${"$(du -skH x)"%%$'\t'*} }
fresh_in_cache() { [[ $(cached) == $(real) ]] }

run zls
check "first run caches x" "$(cached)" "$(real)"

setc 12345 $EPOCHSECONDS $EPOCHSECONDS
run zls
check "reuses the cached size" "$(sizes $OUT)" "12M"

# mtime moved, no measure started lately: re-measured now
touch x
setc 12345 $EPOCHSECONDS $(( EPOCHSECONDS - 700 ))
ago $Y x
run zls
check "changed mtime re-measures" "$(cached)" "$(real)"
[[ $(sizes $OUT) != \~* ]]
check "fresh size has no ~" $? 0

# mtime moved but a measure started recently: last size, ~
setc 12345 $EPOCHSECONDS $EPOCHSECONDS
ago $(( Y / 2 )) x
run zls
check "recently started: not re-measured, ~" \
  "$(sizes $OUT)" "~12M"

# A slow du: zls shows the last known size at once and the
# real one lands in the cache in the background.
mkdir $T/bin
print -r -- "#!/bin/sh
sleep 3
exec $(command -v du) \"\$@\"" > $T/bin/du
chmod +x $T/bin/du
path=($T/bin $path)

old=$(( EPOCHSECONDS - 7200 ))
setc 12345 $old $old
s=$EPOCHREALTIME
run zls
e=$(( EPOCHREALTIME - s ))
check "expired: last size with ~" "$(sizes $OUT)" "~12M"
check "does not wait for du" $(( e < 2.5 )) 1
until_ok 20 fresh_in_cache
check "refreshed in the background" $? 0

mkdir y
ago $Y y
run zls
check "never measured: …" "$(sizes $OUT | sed -n 2p)" "…"
until_ok 20 grep -q "^$PWD/y"$'\t' $cache
check "y measured in the background" $? 0

if (( EUID )); then
  mkdir z
  chmod 000 z
  run zls
  check "unreadable: ?" "$(sizes $OUT | sed -n 3p)" "?"
  chmod 755 z
else
  print -r -- "skip unreadable: running as root"
fi

setc 12345 $EPOCHSECONDS $EPOCHSECONDS
s=$EPOCHREALTIME
run zls -r
e=$(( EPOCHREALTIME - s ))
check "-r waits for du" $(( e >= 2.5 )) 1
check "-r saved the real size" "$(cached)" "$(real)"
[[ $(sizes $OUT | head -1) != \~* ]]
check "-r shows no ~" $? 0

# temp dirs of runs that died long ago are cleaned up
mkdir -p ${cache:h}/run.dead
ago 7200 ${cache:h}/run.dead
old=$(( EPOCHSECONDS - 7200 ))
setc 12345 $old $old
run zls
check "stale temp dir removed" \
  "$([[ -e ${cache:h}/run.dead ]] && print yes || print no)" no

# the cache is parsed, never executed
print -r -- 'garbage line' >> $cache
print -r -- "/x\$(touch $T/pwned)"$'\t1\t1\t1\t1' >> $cache
print -r -- '$(touch '$T'/pwned)'$'\t1\t1\t1\t1' >> $cache
run zls
check "bad lines skipped, never run" \
  "$RC:$([[ -e $T/pwned ]] && print yes || print no)" "0:no"
