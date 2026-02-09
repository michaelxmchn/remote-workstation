#!/bin/bash
# Clash Verge VPN 一键安装脚本 (Ubuntu)
# 用法: sudo ./install.sh

set -e

echo "=========================================="
echo "  Clash Verge VPN 安装脚本"
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

echo -e "${GREEN}[1/6] 更换软件源为阿里云镜像...${NC}"
echo "备份原有源..."
cp /etc/apt/sources.list /etc/apt/sources.list.backup

echo "更换为阿里云镜像..."
sed -i 's|cn.archive.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list
sed -i 's|security.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list

echo -e "${GREEN}[2/6] 更新系统...${NC}"
apt update
apt upgrade -y

echo -e "${GREEN}[3/6] 安装基础工具...${NC}"
apt install -y wget curl unzip

echo -e "${GREEN}[4/6] 安装 Clash Verge...${NC}"

INSTALLED=false

if ls $SCRIPT_DIR/*.deb &> /dev/null; then
    echo "发现本地安装包..."
    DEB_FILE=$(ls $SCRIPT_DIR/*.deb | head -1)
    dpkg -i "$DEB_FILE" || {
        apt-get install -f -y
    }
    INSTALLED=true
fi

if [ "$INSTALLED" = false ]; then
    echo "从 GitHub 下载..."
    cd /tmp
    VERSION=$(curl -sL https://api.github.com/repos/clash-verge-rev/clash-verge-rev/releases/latest | grep "tag_name" | cut -d '"' -f 4)
    if [ -z "$VERSION" ]; then
        VERSION="2.4.5"
    fi
    echo "版本: $VERSION"

    if wget -q "https://github.com/clash-verge-rev/clash-verge-rev/releases/download/${VERSION}/Clash-Verge_${VERSION}_amd64.deb" -O Clash-Verge.deb; then
        dpkg -i Clash-Verge.deb || {
            apt-get install -f -y
        }
        rm -f Clash-Verge.deb
    else
        echo -e "${RED}下载失败${NC}"
        echo "请手动安装或检查网络"
    fi
fi

echo ""
echo -e "${GREEN}[5/6] 安装向日葵...${NC}"
cd /tmp
if ! command -v sunflower &> /dev/null; then
    wget -q https://down.oray.com/sunflower/linux/SunflowerClient_64bit.deb -O sunflower.deb
    dpkg -i sunflower.deb || {
        apt-get install -f -y
    }
    rm -f sunflower.deb
fi

echo ""
echo -e "${GREEN}[6/6] 安装完成！${NC}"
echo ""
echo "=========================================="
echo " 安装完成！"
echo "=========================================="
echo ""
echo -e "${YELLOW}配置步骤:${NC}"
echo ""
echo "   1. 打开 Clash Verge"
echo "   2. 点击左侧 'Profiles(配置)'"
echo "   3. 点击 '+' 添加订阅"
echo -e "${BLUE}   4. 粘贴: $SUB_URL${NC}"
echo "   5. 点击 'Update(更新)'"
echo "   6. 选择节点并启用"
echo ""
echo -e "${YELLOW}订阅信息:${NC}"
echo "   流量: 167GB / 300GB"
echo "   过期: 2025-02-18"
echo ""
echo -e "${RED}注意:${NC}"
echo "   - Clash Verge 在应用程序中查找"
echo "   - 向日葵也在应用程序中"
echo ""
echo "   原始源备份在: /etc/apt/sources.list.backup"
echo ""
