#!/bin/sh
set -eu

mkdir -p "$HOME/sv" "$HOME/var/log/dsh-web" "$HOME/var/log/windbell"
cp -r dsh-web windbell "$HOME/sv/"
