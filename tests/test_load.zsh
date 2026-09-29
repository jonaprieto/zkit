# Loader: autoload and the opt-in aliases.

check "no aliases by default" \
  "${aliases[ls]-none} ${aliases[rm]-none}" \
  "none none"

out=$(zsh -f -c "
  ZKIT_OVERRIDE=(ls rm)
  source $ZKIT/zkit.zsh
  print -r -- \$aliases[ls] \$aliases[rm] \${aliases[update]-none}
")
check "override some" "$out" "zls zrm none"

out=$(zsh -f -c "
  ZKIT_OVERRIDE=all
  source $ZKIT/zkit.zsh
  print -r -- \$aliases[ls] \$aliases[rm] \
    \$aliases[update] \$aliases[tags]
")
check "override all" "$out" "zls zrm zupdate ztags"

out=$(zsh -f -c "
  ZKIT_OVERRIDE=(cp)
  source $ZKIT/zkit.zsh
" 2>&1)
check "unknown override warns" \
  "$out" \
  "zkit: unknown ZKIT_OVERRIDE entry: cp"

out=$(zsh -f -c "
  source $ZKIT/zkit.zsh
  print -r -- \$fpath[1]
")
check "functions dir on fpath" "$out" "$ZKIT/functions"
