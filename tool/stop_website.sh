#!/usr/bin/env bash
# Stops jaspr processes left over from an earlier `website` launch, so a new
# `jaspr serve` can bind its ports (8080 for the site, 8181 for the VM service).
#
# Runs as the preLaunchTask of the `website` config in .vscode/launch.json.
# Only touches Dart processes started in pkgs/website (the jaspr daemon,
# build_runner, the dev server and its DDS) and their children, such as the
# Chrome window jaspr opened for debugging.
set -uo pipefail

dir="$(cd "$(dirname "$0")/../pkgs/website" && pwd -P)"

roots=$(lsof -a -d cwd -c dart -Fpn 2>/dev/null |
  awk -v dir="$dir" '/^p/ { p = substr($0, 2) } /^n/ && substr($0, 2) == dir { print p }')

descendants() {
  local child
  for child in $(pgrep -P "$1"); do
    echo "$child"
    descendants "$child"
  done
}

pids=""
for pid in $roots; do
  pids="$pids $pid $(descendants "$pid")"
done
pids=$(echo $pids | tr ' ' '\n' | sort -un | tr '\n' ' ')

if [ -n "${pids// /}" ]; then
  echo "Stopping earlier website processes: $pids"
  kill -TERM $pids 2>/dev/null
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    alive=$(ps -o pid= -p ${pids// /,} 2>/dev/null)
    [ -z "$alive" ] && break
    sleep 0.5
  done
  [ -n "$alive" ] && kill -KILL $alive 2>/dev/null
fi

holder=$(lsof -nP -iTCP:8181 -sTCP:LISTEN 2>/dev/null | tail -n +2)
if [ -n "$holder" ]; then
  echo "Port 8181 is still in use by a process outside pkgs/website:"
  echo "$holder"
  exit 1
fi
exit 0
