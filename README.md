# JJBench 🚀

> 一款简洁、中文友好的 VPS 一键体检脚本  
> A simple Chinese VPS benchmark & diagnostic tool

---

## ✨ 项目简介

JJBench 是一个轻量级 VPS 体检工具，专为中文用户设计。

目标是：

- 简洁
- 直观
- 不依赖复杂组件
- 一条命令即可运行

适用于：

- 新购 VPS 体检
- 服务器巡检
- 快速环境确认
- 轻量测试

---

## 📦 当前功能 (v0.1)

- 📦 系统信息
  - 主机名
  - 操作系统
  - 内核版本
  - 架构
  - 运行时间（中文显示）

- 🧠 CPU 信息
  - CPU 型号
  - 核心数量
  - 主频

- 💾 内存信息
  - 总内存
  - 使用情况

- 🗄 磁盘信息
  - 磁盘大小
  - 文件系统类型
  - 使用率

- 🌐 网络信息
  - IPv4 地址
  - IPv6 地址

- 🚀 I/O 磁盘写入测试

---

## 🚀 一键运行

无需下载文件，直接执行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/EnockLee/JJBench/main/jjbench.sh)
