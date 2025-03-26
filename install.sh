#!/bin/bash

# 检测操作系统
OS=$(uname -s)
if [ "$OS" != "Darwin" ]; then
    echo "此脚本仅适用于 macOS。请使用 Linux 版本的脚本。"
    exit 1
fi

echo "检测到 macOS，开始安装必要的软件..."

# 更新 Homebrew 并安装依赖
if ! command -v brew &> /dev/null; then
    echo "Homebrew 未安装，正在安装..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update
brew install curl git jq lz4 coreutils

# 安装 Docker
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    brew install --cask docker
    open /Applications/Docker.app
    echo "请手动启动 Docker 并确保其运行正常。"
    read -p "按 Enter 键继续..."
fi

# 安装 Foundry
if ! command -v foundryup &> /dev/null; then
    echo "安装 Foundry..."
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc || source ~/.zshrc
    foundryup
fi

# 下载 Ritual Node
if [ ! -d "$HOME/ritual-node" ]; then
    echo "克隆 Ritual Node 代码库..."
    git clone https://github.com/ritual-network/ritual-node.git $HOME/ritual-node
else
    echo "Ritual Node 目录已存在，跳过克隆。"
fi

# 进入目录并拉取最新代码
cd $HOME/ritual-node || exit

git pull origin main

# 运行 Ritual Node
if docker ps | grep -q ritual-node; then
    echo "Ritual Node 容器已在运行，重启它..."
    docker restart ritual-node
else
    echo "启动 Ritual Node 容器..."
    docker run -d --name ritual-node -p 8545:8545 ritual-network/ritual-node
fi

echo "Ritual Node 安装完成！"
