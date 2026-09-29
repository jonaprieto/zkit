# zcd: numbered cd, errors, plain-cd passthrough.

mkdir -p $T/r/sub $T/r/2
cd $T/r
print x > file

run zls   # 1 2, 2 file, 3 sub
run zcd 3
check "enters numbered dir" "$RC:$PWD" "0:$T/r/sub"

cd $T/r
run zcd 2
check "file: rc 1, stays" \
  "$RC:$PWD:$ERR" "1:$T/r:zcd: not a directory: $T/r/file"

run zcd 9
check "unknown number: rc 1" \
  "$RC:$ERR" "1:zcd: no entry 9 in the last zls"

run zcd sub
check "non-number goes to plain cd" "$RC:$PWD" "0:$T/r/sub"

run zcd -
check "- goes to plain cd" "$RC:$PWD" "0:$T/r"

run zcd -- 2
check "-- 2 enters dir named 2" "$RC:$PWD" "0:$T/r/2"

# the cd runs with the caller's options, not zcd's emulation
out=$(
  setopt autopushd pushdminus
  cd $T/r; cd sub; cd $T/r/2
  zcd -1
  print -r -- $PWD
)
check "-N follows the caller's pushdminus" "$out" "$T/r/sub"

out=$(
  setopt autopushd
  cd $T/r
  zls >/dev/null
  dirs -c
  zcd 3
  print -r -- ${#dirstack}
)
check "zcd N pushes with autopushd" "$out" 1
