#!/usr/bin/env bash

mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
cp gtk-3.0/settings.ini gtk-3.0/gtk.css ~/.config/gtk-3.0/
cp gtk-4.0/settings.ini ~/.config/gtk-4.0/

# libadwaita / GTK4 apps (e.g. the GNOME portal's Nautilus file chooser)
# follow org.gnome.desktop.interface color-scheme, not gtk-theme.
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark || true
fi
