# Changelog

Notable changes to zkit. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- `zcd N` enters the numbered directory. Anything that is not a
  single number (`..`, `-`, `-2`, a path) goes to builtin `cd`
  with your own options, so `cd` can join `ZKIT_OVERRIDE`.
- `ZKIT_HIDE=(.git node_modules '*.log')` leaves matching names
  out of `zls`. Hidden entries get no number, so numbered
  commands never reach them.

## [0.1.0] - 2026-09-29

### Added

- `zls`: numbered listing of every entry, dotfiles included,
  with size, age and name. `-s` / `-t` sort by size or age,
  `+1y` / `-5d` filter by age, `-r` re-measures sizes now.
- Folder sizes cached in `${XDG_CACHE_HOME:-~/.cache}/zkit/du`
  and refreshed in the background; `~` marks a stale size.
- Git column: branch, nearest tag and ahead/behind counts for
  repos in the listing.
- `zrm N...`: confirms, then moves the numbered entries to the
  trash, or runs `rm FLAGS` when flags are given.
- `zupdate N...|--all`: `git pull --ff-only` in the numbered
  repos, one line per repo.
- `ztags N...|--all`: fetch and list tags newest first, with
  the branches that contain them.
- `ZKIT_OVERRIDE` to alias `ls`, `rm`, `update`, `tags` to the
  z-commands.
- Homebrew formula: `brew install jonaprieto/zkit/zkit`.

[Unreleased]: https://github.com/jonaprieto/zkit/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/jonaprieto/zkit/releases/tag/v0.1.0
