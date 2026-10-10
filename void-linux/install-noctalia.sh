#!/usr/bin/env bash
set -euo pipefail

sudo cp xbps.d/voiders-dev-repo.conf /etc/xbps.d &&
    sudo xbps-install -Syu noctalia
