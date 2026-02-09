# 🌐 Ubuntu 远程工作站配置

一键脚本，快速配置远程工作机。

## 功能

- ✅ 自动更新系统
- ✅ 安装基础工具 (curl, wget, git, vim, htop...)
- ✅ 安装向日葵远程控制
- ✅ 安装 Ollama AI 框架
- ✅ 下载 Llama 3.2:3b 模型
- ✅ 配置 SSH

## 使用方法

### 1. 安装 Ubuntu
- 下载 Ubuntu 桌面版 ISO
- 用 U 盘启动安装
- **安装时勾选 "OpenSSH server"**

### 2. 运行配置脚本

```bash
# 下载脚本
git clone https://github.com/michaelxmchn/remote-workstation.git
cd remote-workstation

# 运行脚本（需要 sudo 权限）
sudo bash setup.sh
```

### 3. 配置向日葵
- 打开向日葵应用
- 登录你的账号
- 绑定设备
- 记下设备码（用于远程控制）

## 配置完成后

### SSH 远程登录
```bash
# 查看 IP 地址
hostname -I

# SSH 登录
ssh username@192.168.x.x
```

### Ollama 使用
```bash
# 运行模型
ollama run llama3.2:3b     # 快速响应（2GB）
ollama run deepseek-r1:7b  # 推理能力强（4.7GB）

# 查看已安装模型
ollama list

# 安装其他模型
ollama run qwen2.5:7b      # 中文效果好（4GB）
```

## 系统要求

- Ubuntu 20.04 / 22.04 / 24.04
- 内存: 至少 8GB（推荐 16GB+）
- 存储: 至少 20GB
- 网络: 需要联网下载软件

## 推荐配置

| 用途 | 内存 | 模型 |
|------|------|------|
| 日常对话 | 8GB | llama3.2:3b |
| 推理任务 | 16GB | llama3.2:7b + deepseek-r1:7b |
| 高级用途 | 32GB | 多个大模型 |

## 文件说明

```
remote-workstation/
├── setup.sh           # 主配置脚本
├── README.md          # 说明文档
└── .gitignore
```

## 注意事项

1. 脚本需要 sudo 权限运行
2. 向日葵需要手动登录账号
3. 模型下载需要时间，建议耐心等待
4. 首次运行模型较慢，后续会缓存

## 作者

michaelxmchn

## 许可证

MIT
