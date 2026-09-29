# zrm: confirmation, symlink safety, trash, plain-rm passthrough.

there() { [[ -e $1 || -L $1 ]] && print yes || print no }

mkdir -p $T/r/target
cd $T/r
ln -s target link
print x > file

run zls   # 1 file, 2 link, 3 target
run zrm -rf 2 <<< y
check "link removed" "$(there link)" no
check "target kept" "$(there target)" yes
check "prints absolute paths" "${OUT%%$'\n'*}" "  $PWD/link"

run zls   # 1 file, 2 target
run zrm -f 1 <<< n
check "answer n keeps it, rc 1" "$RC:$(there file)" "1:yes"

run zrm -f 9 <<< y
check "unknown number: rc 1, nothing removed" \
  "$RC:$ERR" "1:zrm: no entry 9 in the last zls"

# no flags: moves to the trash with the trash command
mkdir $T/bin
print -r -- '#!/bin/sh
printf "%s\n" "$@" > '$T'/trashed' > $T/bin/trash
chmod +x $T/bin/trash
(
  path=($T/bin $path)
  rehash
  zrm 1 <<< y
) >$T/.out 2>$T/.err
check "trash gets the absolute path" "$(cat $T/trashed)" "$PWD/file"

# no trash command: refuses, removes nothing
(
  path=()
  zrm 1 <<< y
) >$T/.out 2>$T/.err
rc=$?
msg="zrm: no trash command; pass rm flags"
msg+=" (e.g. zrm -r N) to delete permanently"
check "no trash command: refuses" "$rc:$(cat $T/.err)" "1:$msg"
check "file still there" "$(there file)" yes

print x > 3
run zrm -- 3
check "-- goes to plain rm" "$RC:$(there 3)" "0:no"

run zrm file
check "non-numbers go to plain rm" "$RC:$(there file)" "0:no"
