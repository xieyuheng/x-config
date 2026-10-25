# void linux

`install-apps.sh` 之后，要启动两个服务才能打开 niri：

```sh
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
```

## 关闭笔记本盖子时不要休眠

修改 `/etc/acpi/handler.sh` 末尾的：

```sh
button/lid)
    case "$3" in
        close)
            logger "LID closed, suspending..."
            zzz
            ;;
```

用 drop-in 的方式修改 elogind 的配置：

```sh
sudo mkdir -p /etc/elogind/logind.conf.d
sudo tee /etc/elogind/logind.conf.d/10-lid-ignore.conf >/dev/null <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF
```
