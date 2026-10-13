#!/bin/sh
# tit's tests: each program in tests/programs must print what tests/golden holds. Usage: run.sh [COMPILER]
# TIN_ROOT is a tin checkout (default ../tin) and TIN_DOCS a docs checkout (default ../docs, for the manual check).
set -eu
cd "$(dirname "$0")/.." || exit 1
tin_root=${TIN_ROOT:-../tin}
tin_root=$(cd "$tin_root" && pwd)
docs_root=${TIN_DOCS:-../docs}
docs_root=$(cd "$docs_root" && pwd)
compiler=${1:-$tin_root/bin/tinc}
tin_cmd="$tin_root/tin"
export TIN_ROOT="$tin_root" TIN_DOCS="$docs_root"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
for src in tests/programs/*.tin; do
	name=$(basename "$src" .tin)
	"$compiler" -o "$tmp/$name" "$src"
	"$tmp/$name" > "$tmp/$name.out"
	cmp "$tmp/$name.out" "tests/golden/$name.out" || { echo "FAIL tit $name"; exit 1; }
	echo "PASS tit $name"
done
for dir in */; do
	ls "$dir"*_test.tin >/dev/null 2>&1 || continue
	sh "$tin_cmd" test "$dir" > "$tmp/test.out" 2>&1 || { cat "$tmp/test.out"; echo "FAIL tit tests $dir"; exit 1; }
	echo "PASS tit tests $dir"
done
# every place a secret (a private key) leaves the checker's protection is reviewed: a new one fails here
sh "$tin_cmd" audit secrets main.tin 2>&1 | sed 's/:[0-9]*:[0-9]*:/:/' > "$tmp/reveals.txt"
cmp "$tmp/reveals.txt" tests/reveals.txt || { diff "$tmp/reveals.txt" tests/reveals.txt; echo "FAIL tit reveals: review the change, then update tests/reveals.txt"; exit 1; }
echo "PASS tit reveals"
"$compiler" -o "$tmp/tit" main.tin
"$tmp/tit" version -v > "$tmp/version.out"
cmp "$tmp/version.out" tests/golden/version.out || { echo "FAIL tit version"; exit 1; }
echo "PASS tit version"
# scripted sessions: the same commands as git's, with the same output (golden/session_*.out, from sessions/golden.sh)
for s in tests/sessions/*.sh; do
	name=$(basename "$s" .sh)
	[ "$name" = golden ] && continue
	mkdir "$tmp/session_$name" "$tmp/home_$name"
	HOME="$tmp/home_$name" XDG_CONFIG_HOME="$tmp/home_$name" TZ=UTC sh "$s" "$tmp/tit" "$tmp/session_$name" > "$tmp/session_$name.out" 2>&1 || { cat "$tmp/session_$name.out"; echo "FAIL tit session $name"; exit 1; }
	cmp "$tmp/session_$name.out" "tests/golden/session_$name.out" || { diff "tests/golden/session_$name.out" "$tmp/session_$name.out"; echo "FAIL tit session $name"; exit 1; }
	echo "PASS tit session $name"
done
# scripts that check tit against git themselves (they need git) and exit non-zero on a difference
for s in tests/scripts/*.sh; do
	name=$(basename "$s" .sh)
	mkdir "$tmp/script_$name"
	sh "$s" "$tmp/tit" "$tmp/script_$name" > "$tmp/script_$name.out" 2>&1 || { cat "$tmp/script_$name.out"; echo "FAIL tit script $name"; exit 1; }
	echo "PASS tit script $name"
done
# every capability each package reaches is reviewed: a new one (net, spawn, files) fails here until caps.txt lists it
sh "$tin_cmd" caps main.tin > "$tmp/caps.txt" 2>&1
cmp "$tmp/caps.txt" tests/caps.txt || { diff tests/caps.txt "$tmp/caps.txt"; echo "FAIL tit caps: review the change, then update tests/caps.txt"; exit 1; }
echo "PASS tit caps"
