#!/bin/bash
# Ubuntu 自动化配置脚本 - 远程工作机
# 用法: bash setup-remote-workstation.sh

set -e

echo "=========================================="
echo "  Ubuntu 远程工作站自动化配置"
echo "=========================================="
echo ""

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 需要 root 权限运行${NC}"
    echo "请运行: sudo $0"
    exit 1
fi

# 读取密码（第一次询问）
echo "请输入当前用户的密码（用于 sudo）:"
read -s PASSWORD
echo ""

echo -e "${GREEN}[1/6] 更新系统...${NC}"
echo "$PASSWORD" | sudo -S apt update && sudo apt upgrade -y

echo -e "${GREEN}[2/6] 安装基础工具...${NC}"
echo "$PASSWORD" | sudo -S apt install -y curl wget git vim htop unzip net-tools

echo -e "${GREEN}[3/6] 安装向日葵远程控制...${NC}"
# 下载向日葵
if [ ! -f "/tmp/SunflowerClient_64bit.deb" ]; then
    echo "下载向日葵中..."
    wget -q https://down.oray.com/sunflower/linux/SunflowerClient_64bit.deb -O /tmp/SunflowerClient_64bit.deb
fi

# 安装向日葵
echo "$PASSWORD" | sudo -S dpkg -i /tmp/SunflowerClient_64bit.deb || {
    echo "修复依赖..."
    echo "$PASSWORD" | sudo -S apt-get install -f -y
}
echo -e "${GREEN}✅ 向日葵安装完成${NC}"

echo -e "${GREEN}[4/6] 安装 Ollama...${NC}"
# 安装 Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 启动服务
echo "$PASSWORD" | sudo -S systemctl enable ollama
echo "$PASSWORD" | sudo -S systemctl start ollama

echo -e "${GREEN}[5/6] 下载 AI 模型...${NC}"
# 安装轻量模型（Llama 3.2 3B）- 适合远程工作快速响应
echo "安装 Llama 3.2:3b ..."
ollama run llama3.2:3b || echo "模型安装可能需要时间，请稍后手动安装"

echo -e "${GREEN}[6/6] 配置 SSH...${NC}"
# 安装 SSH
echo "$PASSWORD" | sudo -S apt install -y openssh-server

# 获取 IP 地址
IP_ADDR=$(hostname -I | awk '{print $1}')
echo ""
echo "=========================================="
echo -e "${GREEN}✅ 配置完成！${NC}"
echo "=========================================="
echo ""
echo -e "📋 登录信息:"
echo "   - IP 地址: $IP_ADDR"
echo "   - SSH:     ssh $(whoami)@$IP_ADDR"
echo "   - 向日葵:  在应用菜单中打开"
echo ""
echo -e "📦 已安装:"
echo "   - 向日葵远程控制"
echo "   - Ollama AI 框架"
echo "   - Llama 3.2:3b 模型 (2GB)"
echo ""
echo -e "${YELLOW}⚠️  下一步:${NC}"
echo "   1. 在向日葵中登录你的账号"
echo "   2. 绑定这台电脑"
echo "   3. 记下向日葵显示的设备码"
echo "   4. 其他模型安装: ollama run deepseek-r1:7b"
echo ""
echo "完成！🎉"
