#!/usr/bin/env bash
set -euo pipefail

base=(
    rsync xz tree
)

shell=(
    fish-shell zsh
)

editor=(
    emacs-pgtk vim ranger vscode
)

vcs=(
    git tig
)

lang=(
    nodejs
)

network=(
    ntp NetworkManager
    wget curl proxychains-ng
)

cli=(
    fzf ugrep the_silver_searcher
    fastfetch htop btop ncdu
    amber onefetch
)

dev=(
    clang valgrind cloc gdb libsanitizer libsanitizer-devel
    libX11-devel SDL2-devel
)

media=(
    mpv ffmpeg
)

fonts=(
    noto-fonts-cjk noto-fonts-ttf noto-fonts-ttf-extra
)

docs=(
    zathura zathura-djvu zathura-pdf-mupdf zathura-ps
    djview calibre
    goldendict
)

desktop=(
    niri foot dbus
    xwayland-satellite brillo
    xdg-desktop-portal xdg-desktop-portal-gtk
    xdg-desktop-portal-termfilechooser
)

audio=(
    alsa-utils
    pipewire wireplumber libspa-bluetooth alsa-pipewire
    pulseaudio-utils
)

browser=(
    chromium firefox
)

input=(
    fcitx5 fcitx5-chinese-addons fcitx5-cloudpinyin fcitx5-configtool
    fcitx5-gtk fcitx5-gtk+2 fcitx5-gtk+3 fcitx5-gtk4
    fcitx5-qt fcitx5-qt5 fcitx5-qt6
    fcitx5-rime
)

sudo xbps-install -y \
    "${base[@]}" \
    "${shell[@]}" \
    "${editor[@]}" \
    "${vcs[@]}" \
    "${lang[@]}" \
    "${network[@]}" \
    "${cli[@]}" \
    "${dev[@]}" \
    "${media[@]}" \
    "${fonts[@]}" \
    "${docs[@]}" \
    "${desktop[@]}" \
    "${audio[@]}" \
    "${browser[@]}" \
    "${input[@]}"
