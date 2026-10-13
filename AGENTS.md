# Agent instructions (tit)

tit is version control written in Tin: content-addressed objects, trees and commits, plus operations that can
be undone and change ids that survive amending. It lives in its own repository; the language and toolchain are in
[usetin/tin](https://github.com/usetin/tin), the documentation (the tit manual and the design notes) in
[usetin/docs](https://github.com/usetin/docs).

## Setup and checks

```sh
git clone git@github.com:usetin/tin.git ../tin     # or anywhere: TIN=/path/to/tin
git clone git@github.com:usetin/docs.git ../docs   # or anywhere: TIN_DOCS=/path/to/docs
make build        # bin/tit
make test         # packages, programs, sessions, scripts; minutes
```

- `TIN`/`TIN_ROOT` (Makefile/test scripts) point at the tin checkout; `TIN_DOCS` at the docs checkout
  (the manual check compares tit's usage text with `TIT.md`).
- Parts of the suite need git, openssl, perl and ssh-keygen. `tests/tinrepo.sh` (by hand, Linux) checks
  tit against git on a full clone of the tin repository.
- Golden files (`tests/golden/`, `tests/reveals.txt`, `tests/caps.txt`) are compared exactly. Regenerate
  them only from a verified run: `tests/sessions/golden.sh` and the `tests/*_git.sh` scripts write theirs
  from git itself; `tests/run.sh` prints how the others are updated.
- The manual (`TIT.md`) is in usetin/docs. A new command or flag fails `tests/scripts/docs.sh` until the
  manual documents it; land the manual change in usetin/docs.

## Rules

- Style follows the Tin language: edition 1, tabs, one declaration per line; `../tin/tin fmt` formats.
- A change to the on-disk formats, ids or the protocol is a design change: say so in the message and keep
  the design notes in usetin/docs (`design/tit.md`) in step.
