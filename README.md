# 🚀 Debian Mail Server Auto-Deploy & Management Console

基于 Debian / Ubuntu 的全自动化邮件服务器部署与可视化控制面板（Postfix + Dovecot + SSL + SMTP Relay）。

提供类似于 Sing-box / X-UI 的终端图形化菜单，支持实时系统状态检测、独立账号管理、SMTP 中继转发配置（解决 25 端口封禁）、SSL 自动续期以及快捷命令调用。

---

## ✨ 项目特性

- 🖥️ **可视化终端控制台**：运行 `mail` 命令即可打开综合面板，实时展示服务运行状态、发信工作模式、公网 IP 及 SSL 证书状态。
- ⚙️ **SMTP Relay 中继支持**：一键切换 25 端口直连模式与 SMTP 中继转发模式，完美解决甲骨文云（Oracle Cloud）等 VPS 封禁出站 25 端口问题（原生适配 OCI Email Delivery、Brevo、Resend 等）。
- 🔒 **SSL 全自动续期**：基于 acme.sh 签发 ECC 证书，配置 Postfix / Dovecot 自动重载钩子。
- ⚡ **极高安全性**：强制所有邮箱账号使用 `/bin/false` 禁用系统 SSH 登录权限。
- 🧰 **全功能维护**：一键添加/删除账号、修改密码、配置邮件转发别名（Aliases）及查看实时运行日志。
- 🗑️ **干净彻底卸载**：内置彻底卸载与环境清理脚本。

---

## 🛠️ 一键快捷部署

在全新 Debian / Ubuntu 系统上以 `root` 权限运行：

### 1. curl 方式（完整套件）

**海外 / 通用：**
```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh -o mail.sh && curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh -o deploy.sh && curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/manage.sh -o manage.sh && curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh -o uninstall.sh && chmod +x *.sh && ./mail.sh
```

**国内 CDN 镜像加速：**
```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && curl -sSL https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh -o mail.sh && curl -sSL https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh -o deploy.sh && curl -sSL https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/manage.sh -o manage.sh && curl -sSL https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh -o uninstall.sh && chmod +x *.sh && ./mail.sh
```

---

### 2. wget / bash 方式（完整套件）

**海外 / 通用：**
```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && wget -q https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh -O mail.sh && wget -q https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh -O deploy.sh && wget -q https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/manage.sh -O manage.sh && wget -q https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh -O uninstall.sh && chmod +x *.sh && ./mail.sh
```

**国内 CDN 镜像加速：**
```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && wget -q https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh -O mail.sh && wget -q https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh -O deploy.sh && wget -q https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/manage.sh -O manage.sh && wget -q https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh -O uninstall.sh && chmod +x *.sh && ./mail.sh
```

---

## ⚡ 快捷菜单唤起

安装成功后，在服务器任何目录下直接输入以下命令即可随时调出控制台：

```bash
mail
```

---

## 🌐 甲骨文云（Oracle Cloud）25 端口封禁解决方案

甲骨文云（OCI）默认封禁了 25 出站端口。项目现已内置 SMTP Relay（中继转发）配置：

1. 启动控制台：在服务器输入 `mail` 命令。
2. 进入 **`2) 配置 SMTP Relay 中继`**。
3. 按照提示输入中继服务商提供的 SMTP 服务器地址、587 端口、账号及密码。

### 常用免费 SMTP 中继服务推荐

| 中继服务商 | 免费额度 | 常用端口 | 说明 / 推荐理由 |
| :--- | :--- | :--- | :--- |
| **OCI Email Delivery** | **2,000 封 / 月** | 587 / 2525 | **甲骨文云首选**，内网连通延迟低，信誉度高 |
| **Brevo** (Sendinblue) | **300 封 / 天** | 587 | 注册快速，适合个人日常轻度发信 |
| **Resend** | **3,000 封 / 月** | 587 | 现代极简 API / SMTP 平台，验域名极快 |
| **Amazon SES** | 付费约 $0.10 / 万封 | 587 / 2587 | 极其稳定，适合高频/批量邮件发送 |

> 💡 **提示**：使用任何第三方 SMTP 中继时，请务必在对应中继平台后台添加你的域名，并按要求在 DNS（Cloudflare 等）添加 **SPF** 与 **DKIM** 解析。

---

## 📄 开源协议

[MIT License](LICENSE)
