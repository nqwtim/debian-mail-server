# 🚀 Debian Mail Server Auto-Deploy & Management Console

基于 Debian / Ubuntu 的全自动化邮件服务器部署与可视化控制面板（Postfix + Dovecot + SSL）。

提供类似于 Sing-box / X-UI 的终端图形化菜单，支持实时系统状态检测、独立账号管理、SSL 自动续期以及快捷命令调用。

---

## ✨ 项目特性

- 🖥️ **可视化终端控制台**：运行 `mail` 命令即可打开综合面板，实时展示服务运行状态、公网 IP 及 SSL 证书到期时间。
- 🔒 **SSL 全自动续期**：基于 acme.sh 签发 ECC 证书，配置 Postfix/Dovecot 自动重载钩子。
- ⚡ **极高安全性**：强制所有邮箱账号使用 `/bin/false` 禁用系统 SSH 登录权限。
- 🧰 **全功能维护**：一键添加/删除账号、修改密码、配置邮件转发别名（Aliases）及查看实时运行日志。
- 🗑️ **干净卸载**：内置彻底卸载与环境清理脚本。

---

## 🛠️ 一键快捷部署

在全新 Debian / Ubuntu 系统上以 `root` 权限运行：

### 1. `curl` 方式（完整套件）

**海外/通用：**
```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && curl -sSL [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh) -o mail.sh && curl -sSL [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh) -o deploy.sh && curl -sSL [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh) -o uninstall.sh && chmod +x *.sh && ./mail.sh

**国内 CDN 镜像加速：**
```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && curl -sSL [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh) -o mail.sh && curl -sSL [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh) -o deploy.sh && curl -sSL [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh) -o uninstall.sh && chmod +x *.sh && ./mail.sh

###2. `wget / bash` 方式（完整套件）
**海外/通用：**
```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && wget -q [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh) -O mail.sh && wget -q [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh) -O deploy.sh && wget -q [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh) -O uninstall.sh && chmod +x *.sh && ./mail.sh

**国内 CDN 镜像加速：**
```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && wget -q [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh) -O mail.sh && wget -q [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh) -O deploy.sh && wget -q [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh) -O uninstall.sh && chmod +x *.sh && ./mail.sh

##快捷菜单唤起
**安装成功后，在服务器任何目录下直接输入以下命令即可随时调出控制台：**
```bash
mail

##📄 开源协议
MIT License
