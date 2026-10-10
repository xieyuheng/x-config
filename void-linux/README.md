# void linux

`install-apps.sh` 之后，要启动两个服务才能打开 niri：

```sh
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
```
