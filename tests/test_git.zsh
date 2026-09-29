# git column, zupdate (--ff-only by default), ztags.

g() { git -C "$@" }

# remote with a (v1.0.0) and b; two clones; then c (v1.1.0)
git init -q --bare -b main $T/remote.git
git clone -q $T/remote.git $T/w 2>/dev/null
g $T/w commit -q --allow-empty -m a
g $T/w tag v1.0.0
g $T/w commit -q --allow-empty -m b
g $T/w push -q origin main --tags
mkdir $T/g
git clone -q $T/remote.git $T/g/behind
git clone -q $T/remote.git $T/g/diverged
g $T/w commit -q --allow-empty -m c
g $T/w tag v1.1.0
g $T/w push -q origin main --tags
g $T/g/diverged commit -q --allow-empty -m d
g $T/g/behind fetch -q
g $T/g/diverged fetch -q
# a repo without an upstream
git init -q -b main $T/g/noup
g $T/g/noup commit -q --allow-empty -m x

cd $T/g
run zls
check "git column" "$(names $OUT)" \
  $'behind <main ↓1|v1.0.0 +1>
diverged <main ↑1 ↓1|v1.0.0 +2>
noup <main>'

run zupdate --all
lines=("${(@f)OUT}")
check "zupdate rc 1 when a repo fails" $RC 1
[[ $lines[1] == 'behind '*..*' (+1)' ]]
check "fast-forwards behind" $? 0
check "refuses to merge diverged" "$lines[2]" "diverged failed"
check "diverged untouched" \
  "$(g $T/g/diverged log -1 --format=%s)" d
check "skips no upstream" "$lines[3]" "noup no upstream, skipped"

run ztags 1
lines=("${(@f)OUT}")
check "ztags rc" $RC 0
check "ztags header" "$lines[1]" behind
[[ ${(M)lines:#*v1.1.0*} == *main*'← HEAD' ]]
check "tag at HEAD marked" $? 0
[[ ${(M)lines:#*v1.0.0*} != *HEAD* ]]
check "older tag unmarked" $? 0

run ztags
check "ztags without numbers: usage, rc 1" \
  "$RC:${ERR%%$'\n'*}" \
  "1:ztags: which repos? Use the numbers from zls:"

# ".": the repo you are in, from a subdirectory too
g $T/w commit -q --allow-empty -m e
g $T/w push -q origin main
mkdir $T/g/behind/sub
cd $T/g/behind/sub
run zupdate .
[[ $RC == 0 && $OUT == 'behind '*..*' (+1)' ]]
check "zupdate . pulls the current repo" $? 0
cd $T
run zupdate .
check "zupdate . outside a repo" "$RC:$ERR" \
  "1:zupdate: not in a git repo"
cd $T/g/behind/sub
run ztags .
check "ztags . lists the current repo" "$RC:${OUT%%$'\n'*}" "0:behind"

# -a: all tags instead of the 10 newest
git init -q -b main $T/m/many
g $T/m/many commit -q --allow-empty -m x
for i in {01..12}; do g $T/m/many tag t$i; done
cd $T/m
run zls
run ztags 1
check "10 newest by default" $(( ${#${(f)OUT}} - 1 )) 10
run ztags 1 -a
check "-a shows all" $(( ${#${(f)OUT}} - 1 )) 12
