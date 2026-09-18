#!/usr/bin/env bash
set -euo pipefail

base=(
    rsync xz tree
    make unzip
)

shell=(
    fish-shell zsh
)

editor=(
    emacs-pgtk vim ranger vscode
)

vcs=(
    git tig lazygit
)

lang=(
    nodejs
)

network=(
    ntp NetworkManager bind-utils
    wget curl proxychains-ng
    avahi avahi-utils nss-mdns
)

proxy=(
    shadowsocks-libev sing-box
)

cli=(
    fzf ugrep the_silver_searcher
    fastfetch htop btop ncdu
    amber onefetch
    jq yt-dlp tmux parallel
)

dev=(
    clang valgrind cloc gdb libsanitizer libsanitizer-devel
    libX11-devel SDL2-devel
    nasm fasm global
)

media=(
    mpv ffmpeg vlc mpv-mpris
)

fonts=(
    noto-fonts-cjk noto-fonts-ttf noto-fonts-ttf-extra
)

docs=(
    zathura zathura-djvu zathura-pdf-mupdf zathura-ps
    okular
    djview calibre
    goldendict-ng
)

desktop=(
    niri foot dbus
    noctalia fuzzel rofi
    xwayland-satellite brillo
    imv wl-clipboard
    elogind seatd
    xdg-desktop-portal xdg-desktop-portal-gtk
    xdg-desktop-portal-termfilechooser
)

audio=(
    alsa-utils
    pipewire wireplumber libspa-bluetooth alsa-pipewire
    pulseaudio-utils libjack-pipewire
)

browser=(
    chromium firefox google-chrome
)

input=(
    fcitx5 fcitx5-chinese-addons fcitx5-cloudpinyin fcitx5-configtool
    fcitx5-gtk fcitx5-gtk+2 fcitx5-gtk+3 fcitx5-gtk4
    fcitx5-qt fcitx5-qt5 fcitx5-qt6
    fcitx5-rime
)

power=(
    tlp powertop
)

sudo xbps-install -y \
    "${base[@]}" \
    "${shell[@]}" \
    "${editor[@]}" \
    "${vcs[@]}" \
    "${lang[@]}" \
    "${network[@]}" \
    "${proxy[@]}" \
    "${cli[@]}" \
    "${dev[@]}" \
    "${media[@]}" \
    "${fonts[@]}" \
    "${docs[@]}" \
    "${desktop[@]}" \
    "${audio[@]}" \
    "${browser[@]}" \
    "${input[@]}" \
    "${power[@]}"
