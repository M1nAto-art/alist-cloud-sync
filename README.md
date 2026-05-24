# alist-cloud-sync
AList 多云存储全自动定时增量对撞同步脚本 (支持动态跨年跨月)
# 🚀 AList-Cloud-Sync: 基于 AList API 的多云定时全自动对撞增量备份方案

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

单兵作战建站、折腾图床好伙伴！本脚本通过调用 **AList API** 的文件复制接口，实现从 **Cloudflare R2 (或任意 S3/对象存储)** 定时增量备份文件到 **Google Drive / 任意云盘**。

本地 VPS 仅作指令中转，**物理传输完全在云端服务商之间对撞，不占用你 VPS 的任何上传/下载带宽！**

---

## ✨ 核心特性

- ⚡ **零带宽消耗**：基于 AList 异步复制流，数据不走本地服务器。
- 📅 **智能动态跨年**：自动注入 Linux `$(date +%Y)` 变量，一次配置，终身自动跟随 2026、2027... 跨年不挂科。
- 🧩 **全自动增量**：AList 底层机制遇到同名文件自动跳过，只搬运每天新生成的 WebP/动图，省心高效。
- 📝 **全量日志留痕**：自动向 `/tmp/alist_sync.log` 吐出审计日志，出错一秒破案。

---

## 🛠️ 前置准备

1. **环境**：任意 Linux VPS (本脚本在 Debian/Ubuntu 下完美通过)。
2. **AList 挂载**：确保你的源盘 (如 Cloudflare R2) 和目标盘 (如 Google Drive) 已稳稳挂载在 AList 的存储列表里。
3. **获取令牌**：登录 AList 后台 -> `设置` -> `全局` -> 复制你的 **`令牌 (Token)`**。

---

## 📦 安装与配置

### 方法 A：优雅的脚本流 (推荐 🌟)

1. 下载 `sync.sh` 到你的 VPS：
   ```bash
   curl -O [https://raw.githubusercontent.com/M1nato-art/alist-cloud-sync/main/sync.sh](https://raw.githubusercontent.com/M1nato-art/alist-cloud-sync/main/sync.sh)
   chmod +x sync.sh

2.编辑 sync.sh，将你的 AList Token、源路径、目标路径填入核心参数配置区域。

3.打开 Linux 系统自带的计划任务编辑器：

Bash
crontab -e

4.在最底部添加一行，设置每天凌晨 3:00 全自动执行：

Bash
0 3 * * * /bin/bash /path/to/sync.sh
(注意：请将 /path/to/sync.sh 修改为你脚本存放的真实绝对路径)
