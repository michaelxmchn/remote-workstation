#!/bin/bash
set -e

echo "=========================================="
echo "  Ubuntu 远程工作站配置"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 需要 root 权限${NC}"
    echo "请运行: sudo $0"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "安装目录: $SCRIPT_DIR"

SUB_URL="https://c19808d1e81a2cb012471e4c4f189436.r7kq-2nfa-hg9x-bt4m-y3pw.sbs/s?t=c19808d1e81a2cb012471e4c4f189436.jpg"

echo -e "${GREEN}[1/7] 更换软件源为阿里云镜像...${NC}"
cp /etc/apt/sources.list /etc/apt/sources.list.backup 2>/dev/null || true
sed -i 's|cn.archive.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list 2>/dev/null || true
sed -i 's|security.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list 2>/dev/null || true

echo -e "${GREEN}[2/7] 安装 OpenSSH Server...${NC}"
apt install -y openssh-server
systemctl enable ssh
systemctl start ssh

echo -e "${GREEN}[3/7] 安装基础工具...${NC}"
apt update
apt install -y wget curl unzip htop vim net-tools

echo -e "${GREEN}[4/7] 安装 Clash Verge...${NC}"
if ls $SCRIPT_DIR/*.deb &> /dev/null; then
    echo "发现本地安装包..."
    DEB_FILE=$(ls $SCRIPT_DIR/*.deb | grep Clash | head -1)
    if [ -n "$DEB_FILE" ] && [ -f "$DEB_FILE" ]; then
        dpkg -i "$DEB_FILE" || apt-get install -f -y
    fi
fi

echo -e "${GREEN}[5/7] 安装向日葵远程控制...${NC}"
cd /tmp
if ! command -v sunflower &> /dev/null; then
    wget -q https://down.oray.com/sunflower/linux/SunflowerClient_64bit.deb -O sunflower.deb
    dpkg -i sunflower.deb || apt-get install -f -y
    rm -f sunflower.deb
fi

echo -e "${GREEN}[6/7] 安装 Ollama AI 框架...${NC}"
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
    systemctl enable ollama
    systemctl start ollama
fi

echo ""
echo "=========================================="
echo " ✅ 配置完成！"
echo "=========================================="
echo ""
echo "SSH: ssh $(whoami)@$(hostname -I | awk '{print $1}')"
echo ""
echo "Clash Verge: 打开应用程序，添加订阅: $SUB_URL"
echo ""
