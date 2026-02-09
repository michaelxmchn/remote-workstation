#!/bin/bash
# Ubuntu 远程工作站一键配置脚本
# 用法: sudo ./install.sh

set -e

echo "=========================================="
echo "  Ubuntu 远程工作站配置"
echo "=========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 需要 root 权限${NC}"
    echo "请运行: sudo $0"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "安装目录: $SCRIPT_DIR"
echo ""

SUB_URL="https://c19808d1e81a2cb012471e4c4f189436.r7kq-2nfa-hg9x-bt4m-y3pw.sbs/s?t=c19808d1e81a2cb012471e4c4f189436.jpg"

echo -e "${GREEN}[1/7] 更换软件源为阿里云镜像...${NC}"
echo "备份原有源..."
cp /etc/apt/sources.list /etc/apt/sources.list.backup 2>/dev/null || true

echo "更换为阿里云镜像..."
sed -i 's|cn.archive.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list 2>/dev/null || true
sed -i 's|security.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list 2>/dev/null || true

echo -e "${GREEN}[2/7] 安装 OpenSSH Server...${NC}"
apt install -y openssh-server

# 启用 SSH
systemctl enable ssh
systemctl start ssh

echo -e "${GREEN}[3/7] 安装基础工具...${NC}"
apt update
apt install -y wget curl unzip htop vim net-tools

echo -e "${GREEN}[4/7] 安装 Clash Verge...${NC}"

INSTALLED=false

if ls $SCRIPT_DIR/*.deb &> /dev/null; then
    echo "发现本地安装包..."
    DEB_FILE=$(ls $SCRIPT_DIR/*.deb | grep Clash | head -1)
    if [ -n "$DEB_FILE" ] && [ -f "$DEB_FILE" ]; then
        dpkg -i "$DEB_FILE" || {
            apt-get install -f -y
        }
        INSTALLED=true
        echo "✅ Clash Verge 安装完成"
    fi
fi

if [ "$INSTALLED" = false ]; then
    echo "从 Snap 安装..."
    if command -v snap &> /dev/null; then
        snap install clash-verge-rev || echo "Snap 安装失败，跳过"
    else
        echo "Snap 不可用，跳过 Clash Verge 安装"
    fi
fi

echo ""
echo -e "${GREEN}[5/7] 安装向日葵远程控制...${NC}"
cd /tmp
if ! command -v sunflower &> /dev/null; then
    echo "下载向日葵..."
    wget -q https://down.oray.com/sunflower/linux/SunflowerClient_64bit.deb -O sunflower.deb
    dpkg -i sunflower.deb || {
        apt-get install -f -y
    }
    rm -f sunflower.deb
    echo "✅ 向日葵安装完成"
else
    echo "向日葵已安装"
fi

echo -e "${GREEN}[6/7] 安装 Ollama AI 框架...${NC}"
if ! command -v ollama &> /dev/null; then
    echo "安装 Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    systemctl enable ollama
    systemctl start ollama
    echo "✅ Ollama 安装完成"
else
    echo "Ollama 已安装"
fi

echo ""
echo -e "${GREEN}[7/7] 配置完成！${NC}"
echo ""
echo "=========================================="
echo " ✅ 配置完成！"
echo "=========================================="
echo ""

# 获取 IP 地址
IP_ADDR=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "未知")

echo -e "${YELLOW}📋 登录信息:${NC}"
echo "   - SSH:     ssh $(whoami)@$IP_ADDR"
echo "   - 向日葵:  在应用程序菜单中打开"
echo "   - Clash:   在应用程序菜单中打开"
echo ""

echo -e "${YELLOW}📋 Clash Verge 配置:${NC}"
echo "   1. 打开 Clash Verge"
echo "   2. 点击左侧 'Profiles(配置)'"
echo "   3. 点击 '+' 添加订阅"
echo -e "   4. 粘贴: ${SUB_URL}"
echo "   5. 点击 'Update(更新)'"
echo "   6. 选择节点并启用"
echo ""

echo -e "${YELLOW}📋 订阅信息:${NC}"
echo "   流量: 167GB / 300GB"
echo "   过期: 2025-02-18"
echo ""

echo -e "${YELLOW}📋 Ollama 模型安装:${NC}"
echo "   ollama run llama3.2:3b"
echo "   ollama run deepseek-r1:7b"
echo ""

echo -e "${RED}⚠️  注意:${NC}"
echo "   - 原始源备份在: /etc/apt/sources.list.backup"
echo "   - SSH 默认端口: 22"
echo "   - 向日葵需要登录你的账号"
echo ""
