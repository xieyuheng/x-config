# firefox 手动配置

## 按 Alt 不要开启 menu

地址栏输入 about:config，接受风险提示。
在搜索框中输入 ui.key.menuAccessKeyFocuses。
将其值从 true 修改为 false。

## 关闭崩溃恢复

地址栏输入 about:config，接受风险提示。
搜索 browser.sessionstore.resume_from_crash。
将其值从 true 修改为 false。
