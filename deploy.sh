#!/bin/bash
# Debian / Ubuntu Postfix + Dovecot + acme.sh 全自动邮局部署脚本
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}  Debian Postfix + Dovecot + SSL 全自动邮局部署脚本  ${NC}"
echo -e "${GREEN}====================================================${NC}"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}错误：请使用 root 权限运行此脚本！${NC}"
  exit 1
fi

read -p "1. 请输入主域名 (例如 example.com): " DOMAIN
read -p "2. 请输入邮局完整主机名 (例如 mail.example.com): " MAIL_HOSTNAME
read -p "3. 请输入 SSL 证书通知邮箱 (例如 admin@example.com): " SSL_EMAIL
read -p "4. 请输入初始邮箱用户名 (例如 admin): " MAIL_USER

if [ -z "$DOMAIN" ] || [ -z "$MAIL_HOSTNAME" ] || [ -z "$SSL_EMAIL" ] || [ -z "$MAIL_USER" ]; then
  echo -e "${RED}错误：所有输入参数均不能为空！${NC}"
  exit 1
fi

echo -e "${YELLOW}[1/7] 设置系统主机名...${NC}"
hostnamectl set-hostname "$MAIL_HOSTNAME"

echo -e "${YELLOW}[2/7] 安装依赖与软件包...${NC}"
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt install -y postfix dovecot-imapd dovecot-core mailutils curl socat cron tar

mkdir -p /etc/postfix/certs
chmod 755 /etc/postfix/certs

echo -e "${YELLOW}[3/7] 使用 acme.sh 自动签发 SSL 证书...${NC}"
if [ ! -f "/root/.acme.sh/acme.sh" ]; then
  curl https://get.acme.sh | sh -s email="$SSL_EMAIL"
fi

ACME="/root/.acme.sh/acme.sh"
$ACME --set-default-ca --server letsencrypt

systemctl stop nginx 2>/dev/null || true
systemctl stop apache2 2>/dev/null || true

$ACME --issue -d "$MAIL_HOSTNAME" --standalone --ecc
$ACME --install-cert -d "$MAIL_HOSTNAME" --ecc \
  --key-file       /etc/postfix/certs/privkey.key \
  --fullchain-file /etc/postfix/certs/fullchain.cer \
  --reloadcmd      "systemctl restart postfix dovecot"

chmod 644 /etc/postfix/certs/fullchain.cer
chmod 600 /etc/postfix/certs/privkey.key

echo -e "${YELLOW}[4/7] 配置 Postfix...${NC}"
postconf -e "myhostname = $MAIL_HOSTNAME"
postconf -e "mydomain = $DOMAIN"
postconf -e "myorigin = $DOMAIN"
postconf -e "mydestination = $MAIL_HOSTNAME, localhost.$DOMAIN, localhost, $DOMAIN"
postconf -e "smtpd_tls_cert_file = /etc/postfix/certs/fullchain.cer"
postconf -e "smtpd_tls_key_file = /etc/postfix/certs/privkey.key"
postconf -e "smtpd_tls_security_level = may"
postconf -e "smtpd_tls_auth_only = yes"
postconf -e "smtpd_sasl_type = dovecot"
postconf -e "smtpd_sasl_path = private/auth"
postconf -e "smtpd_sasl_auth_enable = yes"
postconf -e "smtpd_sasl_security_options = noanonymous"
postconf -e "smtpd_sasl_authenticated_header = yes"
postconf -e "broken_sasl_auth_clients = yes"

if [ -f "/usr/share/postfix/master.cf.dist" ]; then
  cp /usr/share/postfix/master.cf.dist /etc/postfix/master.cf
fi

printf "\nsubmission inet n       -       y       -       -       smtpd\n  -o smtpd_tls_security_level=encrypt\n  -o smtpd_sasl_auth_enable=yes\n  -o smtpd_sasl_type=dovecot\n  -o smtpd_sasl_path=private/auth\n  -o smtpd_sasl_security_options=noanonymous\n  -o smtpd_client_restrictions=permit_sasl_authenticated,reject\n" >> /etc/postfix/master.cf

echo -e "${YELLOW}[5/7] 配置 Dovecot...${NC}"
sed -i 's/^#*auth_mechanisms =.*/auth_mechanisms = plain login/' /etc/dovecot/conf.d/10-auth.conf
sed -i 's|^#*ssl_cert =.*|ssl_cert = </etc/postfix/certs/fullchain.cer|' /etc/dovecot/conf.d/10-ssl.conf
sed -i 's|^#*ssl_key =.*|ssl_key = </etc/postfix/certs/privkey.key|' /etc/dovecot/conf.d/10-ssl.conf
sed -i 's/^#*ssl =.*/ssl = required/' /etc/dovecot/conf.d/10-ssl.conf

printf "service imap-login {\n  inet_listener imap {\n    port = 0\n  }\n  inet_listener imaps {\n    port = 993\n    ssl = yes\n  }\n}\nservice pop3-login {\n  inet_listener pop3 {\n    port = 0\n  }\n  inet_listener pop3s {\n    port = 0\n  }\n}\nservice lmtp {\n  unix_listener lmtp {\n  }\n}\nservice auth {\n  unix_listener auth-userdb {\n  }\n  unix_listener /var/spool/postfix/private/auth {\n    mode = 0660\n    user = postfix\n    group = postfix\n  }\n}\nservice auth-worker {\n}\nservice dict {\n  unix_listener dict {\n  }\n}\n" > /etc/dovecot/conf.d/10-master.conf

echo -e "${YELLOW}[6/7] 创建初始用户 $MAIL_USER...${NC}"
if ! id "$MAIL_USER" &>/dev/null; then
  useradd -s /bin/false -m "$MAIL_USER"
  echo -e "${GREEN}设置初始用户 [$MAIL_USER] 密码：${NC}"
  passwd "$MAIL_USER"
fi

echo -e "${YELLOW}[7/7] 重启与激活服务...${NC}"
systemctl restart dovecot postfix
systemctl enable dovecot postfix

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}      🎉 部署成功！证书与自动续期钩子已绑定。      ${NC}"
echo -e "${GREEN}====================================================${NC}"
