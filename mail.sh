#!/bin/bash
# Debian / Ubuntu Mail Server 综合管理控制面板

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
   echo -e "${RED}错误：请使用 root 权限运行此脚本！${NC}"
   exit 1
fi

# 1. 状态获取函数
get_status() {
    OS_NAME=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d'"' -f2)
    SYS_IP=$(curl -s4 --connect-timeout 2 https://api.ipify.org || curl -s4 --connect-timeout 2 https://icanhazip.com || echo "未知IP")
    
    # Postfix 状态
    if systemctl is-active --quiet postfix; then
        POSTFIX_STATUS="${GREEN}运行中${NC}"
    else
        POSTFIX_STATUS="${RED}未运行${NC}"
    fi

    # Dovecot 状态
    if systemctl is-active --quiet dovecot; then
        DOVECOT_STATUS="${GREEN}运行中${NC}"
    else
        DOVECOT_STATUS="${RED}未运行${NC}"
    fi

    # SSL 证书状态
    if [ -f "/etc/postfix/certs/fullchain.cer" ]; then
        CERT_EXP=$(openssl x509 -in /etc/postfix/certs/fullchain.cer -noout -enddate 2>/dev/null | cut -d= -f2)
        SSL_STATUS="${GREEN}已绑定${NC} (到期: ${CERT_EXP:-未知})"
    else
        SSL_STATUS="${RED}未部署证书${NC}"
    fi

    # 邮箱账号数量统计 (读取 shell 为 /bin/false 的普通用户)
    MAIL_USERS_COUNT=$(awk -F: '$7 == "/bin/false" {print $1}' /etc/passwd | wc -l)
}

# 2. 菜单界面渲染
show_menu() {
    clear
    get_status
    echo -e "${CYAN}=================================================================${NC}"
    echo -e "${GREEN} Debian / Ubuntu Postfix + Dovecot + SSL 邮局一体化管理面板${NC}"
    echo -e " 快捷调用命令: ${YELLOW}mail${NC}"
    echo -e "${CYAN}=================================================================${NC}"
    echo -e " ${GREEN}1.${NC} 一键安装 / 部署邮局环境"
    echo -e " ${RED}2. 彻底卸载邮局服务与环境${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------${NC}"
    echo -e " ${GREEN}3.${NC} 添加新邮箱账号             ${GREEN}4.${NC} 删除已有邮箱账号"
    echo -e " ${GREEN}5.${NC} 修改邮箱账号密码           ${GREEN}6.${NC} 查看所有邮箱账号列表"
    echo -e " ${GREEN}7.${NC} 添加/管理邮件转发别名(Aliases)"
    echo -e "${CYAN}-----------------------------------------------------------------${NC}"
    echo -e " ${GREEN}8.${NC} 检查 / 手动强制续期 SSL 证书"
    echo -e " ${GREEN}9.${NC} 查看邮局服务实时运行日志"
    echo -e " ${GREEN}10.${NC} 重启邮局核心服务 (Postfix + Dovecot)"
    echo -e " ${GREEN}11.${NC} 修复/设置系统快捷键 [mail]"
    echo -e " ${GREEN}0.${NC} 退出脚本"
    echo -e "${CYAN}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    echo -e " ${YELLOW}VPS 状态如下：${NC}"
    echo -e " 系统版本 : ${OS_NAME}"
    echo -e " 公网 IP  : ${SYS_IP}"
    echo -e " Postfix  : ${POSTFIX_STATUS} (端口: 25, 587)"
    echo -e " Dovecot  : ${DOVECOT_STATUS} (端口: 993)"
    echo -e " SSL 证书 : ${SSL_STATUS}"
    echo -e " 已存账号 : ${YELLOW}${MAIL_USERS_COUNT}${NC} 个独立邮箱用户"
    echo -e "${CYAN}=================================================================${NC}"
}

# 3. 功能交互逻辑
set_shortcut() {
    ln -sf "$(pwd)/mail.sh" /usr/local/bin/mail
    chmod +x /usr/local/bin/mail
    echo -e "${GREEN}✅ 已成功将快捷指令注册为 [mail]！今后在任何目录下输入 mail 即可直接调出控制台。${NC}"
}

list_users() {
    echo -e "\n${YELLOW}=== 当前服务器上的所有邮箱账号 ===${NC}"
    awk -F: '$7 == "/bin/false" {print " - " $1}' /etc/passwd
    echo ""
}

show_logs() {
    echo -e "${YELLOW}正在查看邮局实时日志 (按 Ctrl+C 退出查看)...${NC}"
    if [ -f "/var/log/mail.log" ]; then
        tail -n 50 -f /var/log/mail.log
    else
        journalctl -u postfix -u dovecot -f -n 50
    fi
}

# 循环主菜单
set_shortcut >/dev/null 2>&1

while true; do
    show_menu
    read -p "请输入选项 [0-11]: " choice
    case $choice in
        1)
            bash ./deploy.sh
            read -p "按回车键继续..."
            ;;
        2)
            bash ./uninstall.sh
            read -p "按回车键继续..."
            ;;
        3)
            read -p "请输入新邮箱用户名: " username
            if [ -n "$username" ]; then
                useradd -s /bin/false -m "$username" && passwd "$username"
            fi
            read -p "按回车键继续..."
            ;;
        4)
            list_users
            read -p "请输入要删除的用户名: " del_user
            if [ -n "$del_user" ]; then
                userdel -r "$del_user" 2>/dev/null
                echo -e "${GREEN}用户 $del_user 已安全彻底删除。${NC}"
            fi
            read -p "按回车键继续..."
            ;;
        5)
            list_users
            read -p "请输入要修改密码的用户名: " ch_user
            if [ -n "$ch_user" ]; then
                passwd "$ch_user"
            fi
            read -p "按回车键继续..."
            ;;
        6)
            list_users
            read -p "按回车键继续..."
            ;;
        7)
            read -p "请输入前缀别名 (如 info): " alias_name
            read -p "请输入接收别名邮件的目标用户名: " target_user
            if [ -n "$alias_name" ] && [ -n "$target_user" ]; then
                echo "${alias_name}: ${target_user}" >> /etc/aliases
                newaliases
                echo -e "${GREEN}✅ 别名 ${alias_name} -> ${target_user} 创建成功！${NC}"
            fi
            read -p "按回车键继续..."
            ;;
        8)
            echo -e "${YELLOW}正在使用 acme.sh 检查与续期 SSL 证书...${NC}"
            /root/.acme.sh/acme.sh --cron --home /root/.acme.sh
            systemctl restart postfix dovecot
            read -p "按回车键继续..."
            ;;
        9)
            show_logs
            ;;
        10)
            systemctl restart postfix dovecot
            echo -e "${GREEN}✅ Postfix 和 Dovecot 服务已成功重启！${NC}"
            sleep 1.5
            ;;
        11)
            set_shortcut
            sleep 1.5
            ;;
        0)
            echo -e "${GREEN}感谢使用，再见！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}错误：无效选项！${NC}"
            sleep 1
            ;;
    esac
done
