#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "错误：请使用 root 权限运行此脚本！"
  exit 1
fi

echo "=========================================="
echo "         Debian 邮局管理工具             "
echo "=========================================="
echo "1) 添加新邮箱账号"
echo "2) 添加邮箱转发别名"
echo "3) 退出"
echo "=========================================="
read -p "请选择 [1-3]: " choice

case $choice in
  1)
    read -p "请输入新用户名 (例如 alex): " username
    if id "$username" &>/dev/null; then
        echo "错误：用户 '$username' 已存在！"
        exit 1
    fi
    useradd -s /bin/false -m "$username"
    echo "请为用户 '$username' 设置密码："
    passwd "$username"
    echo "✅ 账号创建成功！"
    ;;
  2)
    read -p "请输入前缀别名 (例如 info): " alias_name
    read -p "请输入目标用户名 (例如 ham): " target_user
    echo "${alias_name}: ${target_user}" >> /etc/aliases
    newaliases
    echo "✅ 别名设置成功！"
    ;;
  3)
    exit 0
    ;;
  *)
    echo "无效选项！"
    exit 1
    ;;
esac
