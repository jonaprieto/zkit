# zkit: zsh commands. Source this file from ~/.zshrc.
#
# Set ZKIT_OVERRIDE=(ls rm update tags cd), or
# ZKIT_OVERRIDE=all, before sourcing to alias those plain names
# to zls, zrm, zupdate, ztags and zcd. Aliases apply only to
# interactive command lines, never to scripts.

0=${(%):-%N}
typeset -g ZKIT_DIR=${0:A:h}
fpath=($ZKIT_DIR/functions $fpath)
autoload -Uz $ZKIT_DIR/functions/*(N.:t)

() {
  emulate -L zsh
  local n
  local -a known=(ls rm update tags cd)
  local -a want=($ZKIT_OVERRIDE)
  [[ $want == all ]] && want=($known)
  for n in $want; do
    if (( $known[(Ie)$n] )); then
      alias $n=z$n
    else
      print -u2 "zkit: unknown ZKIT_OVERRIDE entry: $n"
    fi
  done
}
