#!/usr/bin/env bash

# (a) 装软件包（或只 xbps-install 新增的那几个）
bash void-linux/install-apps.sh

# (b) 安装配置 —— 这些脚本是就地 cp，必须在各自目录里执行
(cd bin                                  && bash install.sh)   # start-niri 等
(cd niri                                 && bash install.sh)   # 含浮动窗口规则
(cd xdg-desktop-portal                   && bash install.sh)   # niri-portals.conf
(cd xdg-desktop-portal-termfilechooser   && bash install.sh)   # ranger/foot 配置
(cd gtk                                  && bash install.sh)   # 深色（可选）
