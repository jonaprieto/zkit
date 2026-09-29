# zkit

[![CI](https://github.com/jonaprieto/zkit/actions/workflows/ci.yml/badge.svg)](https://github.com/jonaprieto/zkit/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/jonaprieto/zkit?include_prereleases)](https://github.com/jonaprieto/zkit/releases)
[![License: MIT](https://img.shields.io/github/license/jonaprieto/zkit)](LICENSE)
[![Site](https://img.shields.io/badge/site-zkit-87ff87)](https://jonaprieto.github.io/zkit/)
[![Homebrew](https://img.shields.io/badge/brew-jonaprieto%2Fzkit-fbb040?logo=homebrew)](#install)

zsh commands, starting with a numbered listing that shows folder
sizes (cached, refreshed in the background), how long ago things
changed, and git status, plus commands that act on the numbers.

```
$ zls
  1   4.0K   3y  .editorconfig
  2   1.2G  2mo  data
  3    38M   5d  site <main ↑1|v2.3.0 +4>
  4   ~12G   0m  videos
$ zrm 2        # asks, then moves data to the trash
$ zupdate 3    # git pull --ff-only in site
```

## Install

```sh
brew tap jonaprieto/zkit https://github.com/jonaprieto/zkit
brew trust --formula jonaprieto/zkit/zkit   # third-party taps need it
brew install zkit
echo 'source $(brew --prefix)/share/zkit/zkit.zsh' >> ~/.zshrc
```

Or clone the repo and `source path/to/zkit/zkit.zsh`. Needs zsh
and [eza](https://github.com/eza-community/eza).

## Commands

| Command | What it does |
| --- | --- |
| `zls [DIR]` | number, size, age and name of every entry, dotfiles included |
| `zls -s` / `-t` / `-st` | sort by size / age, biggest or oldest last; a second letter breaks ties |
| `zls +1y` / `-5d` | only entries older / newer than that (`m h d w mo y`) |
| `zls -r` | re-measure folder sizes now and wait |
| `zrm [FLAGS] N...` | confirm, then trash (no flags) or `rm FLAGS` the numbered entries |
| `zupdate N...\|--all\|. [FLAGS]` | `git pull --ff-only` (or your flags) in the numbered repos, or `.` for the one you are in |
| `ztags N...\|--all\|. [-a]` | fetch and list tags, newest first, with the branches containing them |
| `zcd N` | cd into the numbered directory; anything else goes to plain `cd` |

A size marked `~` is the last known one and is being refreshed;
`…` means not measured yet, `?` unreadable.

## Configuration

- `ZKIT_OVERRIDE=(ls rm update tags cd)` (or `all`), set before
  sourcing, aliases the plain names to the z-commands.
- `ZKIT_HIDE=(.git .DS_Store node_modules '*.log')` hides
  matching names from `zls`; hidden entries get no number.
- Sizes are cached in `${XDG_CACHE_HOME:-~/.cache}/zkit/du`.
