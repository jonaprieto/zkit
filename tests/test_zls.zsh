# zls: numbering, order, sorts, age filters, symlinks, eza.

mkdir -p $T/d/a $T/d/b $T/d/.h
cd $T/d
print hi > c.txt
ago $(( 5 * Y + 1000 )) .h

run zls
check "rc 0" $RC 0
check "alphabetical with dotfiles" \
  "$(names $OUT)" \
  $'.h\na\nb\nc.txt'
check "numbers" "$(nums $OUT | paste -sd' ' -)" "1 2 3 4"
check "paths recorded" "$_zkit_paths[2]" "$PWD/a"
check "old dotdir age" "$(ages $OUT | head -1)" "5y"
[[ $(sizes $OUT | head -3) != *[…~?]* ]]
check "folders are measured" $? 0

# sizes (-s) and ages (-t): biggest / oldest last
mkdir $T/s
cd $T/s
head -c 1000 /dev/zero > small
head -c 200000 /dev/zero > mid
head -c 2000000 /dev/zero > large
ago $(( 3 * Y )) large
ago $(( Y * 3 / 2 )) small
ago $(( Y / 2 )) mid

run zls -s
check "-s biggest last" "$(names $OUT)" $'small\nmid\nlarge'

run zls -t
check "-t oldest last" "$(names $OUT)" $'mid\nsmall\nlarge'
check "numbers follow display" "$_zkit_paths[1]" "$PWD/mid"

# a copy has exactly the same blocks: a size tie on any fs
cp small twin
ago $(( Y * 5 / 2 )) twin
run zls -st
check "-st ties by age" \
  "$(names $OUT)" \
  $'small\ntwin\nmid\nlarge'

# age filters
run zls +2y
check "+2y older" "$(names $OUT)" $'large\ntwin'
run zls -2y
check "-2y newer" "$(names $OUT)" $'mid\nsmall'
run zls 2y
check "bare 2y newer" "$(names $OUT)" $'mid\nsmall'

# symlinks and future mtimes
mkdir $T/l
cd $T/l
mkdir real
ln -s nowhere broken
ln -s real link
touch future
ago -86400 future

run zls
check "symlink arrows" \
  "$(names $OUT)" \
  $'broken → nowhere\nfuture\nlink → real\nreal'
check "link path is the link" "$_zkit_paths[3]" "$PWD/link"
check "future counts as now" "$(ages $OUT | sed -n 2p)" "0m"

# empty dir, DIR argument, eza passthrough, conflicts
mkdir $T/e
run zls $T/e
check "empty dir" "$RC:$OUT" "0:"

run zls $T/s
check "DIR argument" "$(names $OUT | head -1)" "large"

run zls -s -l
check "conflict rc" $RC 1
msg="zls: -r, -s, -t and age filters don't combine"
msg+=" with other flags or several paths"
check "conflict message" "$ERR" "$msg"

run zls -1 $T/s
check "other flags go to eza" \
  "$RC:$(print -r -- $OUT | head -1)" \
  "0:large"

# ZKIT_HIDE: matching names are left out and get no number
mkdir -p $T/hide/.git $T/hide/node_modules $T/hide/src
cd $T/hide
print x > app.log
print x > main.c
ZKIT_HIDE=(.git node_modules '*.log')
run zls
check "ZKIT_HIDE hides names and globs" \
  "$(names $OUT)" $'main.c\nsrc'
check "hidden entries get no number" "$_zkit_paths[2]" "$PWD/src"

# the fallback numbering (no zls yet) skips them too
out=$(_zkit_paths=(); zcd 2; print -r -- $PWD)
check "fallback numbering honors ZKIT_HIDE" "$out" "$PWD/src"
unset ZKIT_HIDE
