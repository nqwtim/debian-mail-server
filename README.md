# 🚀 Debian Production-Grade Mail Server


## 📖 项目简介

一个专为 Debian 系统打造的生产级、高送达率、易管理的轻量级邮件服务器自动化部署与管理套件。支持 Postfix、Dovecot、OpenDKIM、Let's Encrypt，并支持 SMTP Relay（如 OCI、Brevo 等）绕过云厂商 25 端口限制。

---

## 📥 一键部署

### 方式一：curl（GitHub）

```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server

curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh -o mail.sh
curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh -o deploy.sh
curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/manage.sh -o manage.sh
curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh -o uninstall.sh

chmod +x *.sh
./mail.sh
```

### 方式二：Git Clone

```bash
git clone https://github.com/nqwtim/debian-mail-server.git ~/debian-mail-server
cd ~/debian-mail-server
chmod +x *.sh
./mail.sh
```

---

## 🛠️ 脚本说明

| 文件 | 功能 |
|------|------|
| `mail.sh` | 主控制面板 |
| `deploy.sh` | 自动部署 Postfix、Dovecot、OpenDKIM、SSL |
| `manage.sh` | 邮箱账户管理 |
| `uninstall.sh` | 一键卸载 |

---

## 🌐 DNS 配置

### A

```
mail -> VPS 公网 IP
```

### MX

```
@ -> mail.yourdomain.com
Priority: 10
```

### SPF

```text
v=spf1 mx ip4:YOUR_SERVER_IP ~all
```

OCI Relay：

```text
v=spf1 mx include:oraclecloud.com ~all
```

Brevo：

```text
v=spf1 mx include:spf.brevo.com ~all
```

### DKIM

部署完成后执行：

```bash
cat /etc/postfix/dkim/mail.txt
```

复制 `p=` 后面的公钥写入：

```
mail._domainkey
```

TXT 记录。

### DMARC

```text
v=DMARC1; p=none; rua=mailto:dmarc-reports@yourdomain.com; ruf=mailto:dmarc-reports@yourdomain.com; fo=1;
```

### PTR (rDNS)

在 VPS 控制台将服务器 IP 的 PTR 设置为：

```
mail.yourdomain.com
```

---

## 🔎 推荐检测

- Mail-Tester（邮件评分）
- MXToolbox（MX/SPF/DKIM）
- DMARC Analyzer（DMARC）

---

## 📄 License

MIT License
