# 🚀 Debian Mail Server Auto-Deploy

基于 Debian / Ubuntu 的全自动化邮件服务器一键部署项目（Postfix + Dovecot + SSL）。

适用于快速搭建个人/企业邮局，全自动申请与续期 Let's Encrypt SSL 证书，完美兼容 Outlook、Apple Mail、Thunderbird 等主流邮件客户端。

---

## ✨ 项目特性

- 🔒 **SSL 全自动续期**：基于 acme.sh 签发 ECC 证书，配置 Postfix/Dovecot 自动重载钩子。
- ⚡ **安全隔离机制**：禁用系统 SSH 登录权限（/bin/false），开放 993 (IMAPS) 与 587 (Submission) 加密端口。
- 🛠️ **全客户端兼容**：支持 PLAIN 与 LOGIN SASL 认证，解决 Outlook 登录提示问题。
- 🧰 **配套管理工具**：提供管理脚本，支持一键添加独立账号及邮件转发别名（Aliases）。

---

## 🛠️ 一键部署

在全新的 Debian / Ubuntu 系统上用 `root` 权限直接运行：

```bash
bash <(curl -sSL [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh))

📄 开源协议
MIT License
