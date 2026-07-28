#!/bin/bash
# Debian / Ubuntu Mail Server 彻底卸载脚本

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
   echo -e "${RED}错误：请使用 root 权限运行此脚本！${NC}"
   exit 1
fi

echo -e "${RED}====================================================${NC}"
echo -e "${RED}       ⚠️ 警告：即将在当前系统彻底卸载邮局环境 ⚠️       ${NC}"
echo -e "${RED}====================================================${NC}"
echo -e "此操作将执行以下动作："
echo -e " 1. 停止并卸载 Postfix、Dovecot 等邮局核心组件"
echo -e " 2. 清除 /etc/postfix 和 /etc/dovecot 配置目录与证书"
echo -e " 3. 移除系统快捷命令 [mail]"
echo -e "${RED}----------------------------------------------------${NC}"
read -p "确认要彻底卸载吗？(输入 y 确认, 其它任意键取消): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo -e "${GREEN}已取消卸载操作。${NC}"
    exit 0
fi

echo -e "${YELLOW}[1/4] 停止相关服务...${NC}"
systemctl stop postfix dovecot 2>/dev/null || true
systemctl disable postfix dovecot 2>/dev/null || true

echo -e "${YELLOW}[2/4] 彻底卸载软件包及其配置文件...${NC}"
DEBIAN_FRONTEND=noninteractive apt-get purge -y postfix dovecot-imapd dovecot-core mailutils 2>/dev/null || true
DEBIAN_FRONTEND=noninteractive apt-get autoremove -y

echo -e "${YELLOW}[3/4] 清理残留配置文件夹与 SSL 证书...${NC}"
rm -rf /etc/postfix
rm -rf /etc/dovecot
rm -f /usr/local/bin/mail

echo -e "${YELLOW}[4/4] 询问是否清理已创建的邮箱用户...${NC}"
read -p "是否同步删除通过本脚本创建的邮箱用户及家目录？(y/N): " del_users
if [ "$del_users" = "y" ] || [ "$del_users" = "Y" ]; then
    for u in $(awk -F: '$7 == "/bin/false" {print $1}' /etc/passwd); do
        userdel -r "$u" 2>/dev/null
        echo "已删除邮箱用户: $u"
    done
fi

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}      🎉 邮局环境已彻底卸载与清理干净！             ${NC}"
echo -e "${GREEN}====================================================${NC}"
