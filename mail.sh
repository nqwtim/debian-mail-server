#!/usr/bin/env bash

# ====================================================
# Debian Mail Server Auto-Deploy & Management Console
# Mail Control Panel Script (Clean ASCII UI)
# ====================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误：请使用 root 权限运行此脚本。${NC}"
    exit 1
fi

# 获取当前发信模式状态
get_relay_status() {
    CURRENT_RELAY=$(postconf -h relayhost 2>/dev/null)
    if [ -n "$CURRENT_RELAY" ]; then
        echo -e "${GREEN}中继转发 (${CURRENT_RELAY})${NC}"
    else
        echo -e "${YELLOW}25 端口直连${NC}"
    fi
}

# 获取服务运行状态
get_service_status() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        echo -e "${GREEN}运行中${NC}"
    else
        echo -e "${RED}已停止${NC}"
    fi
}

# 1. 账号管理
manage_users() {
    if [ -f "./manage.sh" ]; then
        bash ./manage.sh
    else
        echo -e "${RED}错误：未找到 manage.sh 脚本！${NC}"
        read -p "按回车键继续..."
    fi
}

# 2. SMTP Relay 配置功能
setup_smtp_relay() {
    clear
    echo -e "${CYAN}+----------------------------------------------------+${NC}"
    echo -e "${CYAN}|         SMTP Relay 中继设置 (规避 25 端口限制)     |${NC}"
    echo -e "${CYAN}+----------------------------------------------------+${NC}"
    
    CURRENT_RELAY=$(postconf -h relayhost 2>/dev/null)
    if [ -n "$CURRENT_RELAY" ]; then
        echo -e " 当前发信模式: ${GREEN}已启用 SMTP 中继 (${CURRENT_RELAY})${NC}\n"
    else
        echo -e " 当前发信模式: ${YELLOW}未启用 (25 端口直连模式)${NC}\n"
    fi

    echo -e "  [1] 配置 / 修改 SMTP 中继 (支持 OCI / Brevo / Resend 等)"
    echo -e "  [2] 测试当前 SMTP 中继节点连通性"
    echo -e "  [3] 禁用 SMTP 中继 (恢复 25 端口直连)"
    echo -e "  [0] 返回主菜单"
    echo -e "${CYAN}+----------------------------------------------------+${NC}"
    read -p " 请选择操作 [0-3]: " relay_choice

    case "$relay_choice" in
        1)
            echo -e "\n${YELLOW}[请输入中继服务商提供的 SMTP 信息]${NC}"
            read -p " 1. SMTP 服务器地址 (如: smtp.email.us-sanjose-1.oraclecloud.com): " RELAY_HOST
            read -p " 2. SMTP 端口 [默认: 587]: " RELAY_PORT
            RELAY_PORT=${RELAY_PORT:-587}
            read -p " 3. SMTP 账号/Username: " RELAY_USER
            read -p " 4. SMTP 密码/Password: " RELAY_PASS

            if [ -z "$RELAY_HOST" ] || [ -z "$RELAY_USER" ] || [ -z "$RELAY_PASS" ]; then
                echo -e "${RED}错误：所有必填项均不可为空！${NC}"
                read -p "按回车键继续..."
                return
            fi

            echo -e "\n${BLUE}正在配置 SASL 认证凭据...${NC}"
            echo "[${RELAY_HOST}]:${RELAY_PORT}  ${RELAY_USER}:${RELAY_PASS}" > /etc/postfix/sasl_passwd
            chmod 600 /etc/postfix/sasl_passwd
            postmap /etc/postfix/sasl_passwd

            echo -e "${BLUE}正在更新 Postfix 参数...${NC}"
            postconf -e "relayhost = [${RELAY_HOST}]:${RELAY_PORT}"
            postconf -e "smtp_sasl_auth_enable = yes"
            postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
            postconf -e "smtp_sasl_security_options = noanonymous"
            postconf -e "smtp_tls_security_level = encrypt"
            
            if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
                postconf -e "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt"
            fi

            systemctl restart postfix
            echo -e "${GREEN}SUCCESS: SMTP 中继配置完成，Postfix 已重启！${NC}"
            read -p "按回车键继续..."
            ;;
        2)
            if [ -z "$CURRENT_RELAY" ]; then
                echo -e "${RED}错误：当前未启用 SMTP 中继，无法测试！${NC}"
            else
                RELAY_HOST_ONLY=$(echo "$CURRENT_RELAY" | tr -d '[]' | cut -d: -f1)
                RELAY_PORT_ONLY=$(echo "$CURRENT_RELAY" | tr -d '[]' | cut -d: -f2)
                echo -e "\n${BLUE}正在测试与 ${RELAY_HOST_ONLY}:${RELAY_PORT_ONLY} 的网络连通性...${NC}"
                
                if command -v nc >/dev/null 2>&1; then
                    nc -zv -w 5 "$RELAY_HOST_ONLY" "$RELAY_PORT_ONLY"
                else
                    timeout 5 bash -c "</dev/tcp/${RELAY_HOST_ONLY}/${RELAY_PORT_ONLY}" 2>/dev/null
                fi

                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}SUCCESS: 端口连通正常！中继节点网络畅通。${NC}"
                else
                    echo -e "${RED}ERROR: 无法连接到 ${RELAY_HOST_ONLY}:${RELAY_PORT_ONLY}，请检查防火墙。${NC}"
                fi
            fi
            read -p "按回车键继续..."
            ;;
        3)
            echo -e "\n${YELLOW}正在清理中继配置...${NC}"
            postconf -e "relayhost ="
            postconf -e "smtp_sasl_auth_enable = no"
            rm -f /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
            systemctl restart postfix
            echo -e "${GREEN}SUCCESS: 已禁用 SMTP 中继，恢复 25 端口直连。${NC}"
            read -p "按回车键继续..."
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}无效选项！${NC}"
            sleep 1
            ;;
    esac
}

# 3. 日志查看
show_logs() {
    clear
    echo -e "${CYAN}+----------------------------------------------------+${NC}"
    echo -e "${CYAN}|               邮件服务实时运行日志                 |${NC}"
    echo -e "${CYAN}+----------------------------------------------------+${NC}"
    echo "提示: 按 Ctrl + C 即可退出日志查看"
    echo "----------------------------------------------------"
    journalctl -u postfix -u dovecot -f -n 50
}

# 4. 重启服务
restart_services() {
    echo -e "\n${BLUE}正在重启 Postfix 与 Dovecot...${NC}"
    systemctl restart postfix dovecot
    echo -e "${GREEN}SUCCESS: 服务重启成功！${NC}"
    sleep 1.5
}

# 5. 在线更新脚本
update_script() {
    echo -e "\n${BLUE}正在拉取 GitHub 最新版本的管理脚本...${NC}"
    cd ~/debian-mail-server || exit 1
    
    curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh -o mail.sh
    curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh -o deploy.sh
    curl -sSL https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh -o uninstall.sh
    chmod +x *.sh
    
    echo -e "${GREEN}SUCCESS: 控制台脚本已成功更新！即将重启控制台...${NC}"
    sleep 1.5
    exec ./mail.sh
}

# 主菜单
show_menu() {
    while true; do
        clear
        PUBLIC_IP=$(curl -s -4 ifconfig.me || echo "未知")
        
        echo -e "${CYAN}+----------------------------------------------------+${NC}"
        echo -e "${CYAN}|          Debian Mail Server 控制面板               |${NC}"
        echo -e "${CYAN}+----------------------------------------------------+${NC}"
        echo -e "  服务器公网 IP  : ${YELLOW}${PUBLIC_IP}${NC}"
        echo -e "  Postfix (SMTP) : $(get_service_status postfix)"
        echo -e "  Dovecot (IMAP) : $(get_service_status dovecot)"
        echo -e "  发信工作模式   : $(get_relay_status)"
        echo -e "${CYAN}+----------------------------------------------------+${NC}"
        echo -e "  [1] 邮箱账号管理 (添加 / 删除 / 修改密码)"
        echo -e "  [2] 配置 SMTP Relay 中继 (解决 25 端口限制)"
        echo -e "  [3] 查看邮件服务实时日志"
        echo -e "  [4] 重启邮件核心组件"
        echo -e "  [5] 在线检查并更新控制台脚本"
        echo -e "  [6] 彻底卸载 Mail Server"
        echo -e "  [0] 退出控制台"
        echo -e "${CYAN}+----------------------------------------------------+${NC}"
        read -p " 请输入选项 [0-6]: " choice

        case "$choice" in
            1) manage_users ;;
            2) setup_smtp_relay ;;
            3) show_logs ;;
            4) restart_services ;;
            5) update_script ;;
            6) 
                if [ -f "./uninstall.sh" ]; then
                    bash ./uninstall.sh
                    exit 0
                else
                    echo -e "${RED}未找到 uninstall.sh${NC}"
                    sleep 1
                fi
                ;;
            0)
                echo -e "${GREEN}已退出控制台。${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}输入无效，请重新输入！${NC}"
                sleep 1
                ;;
        esac
    done
}

show_menu
