# 🚀 AList-Cloud-Sync: 基于 AList API 的多云定时全自动对撞增量备份方案

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

单兵作战建站、折腾图床的好伙伴！本方案通过调用 **AList API** 的文件复制接口，实现从 **Cloudflare R2 (或任意 S3/对象存储)** 定时增量备份文件到 **Google Drive / 任意云盘**。

本地 VPS 仅作指令中转，**物理传输完全在云端服务商之间进行数据对撞，不占用你 VPS 的任何上传/下载带宽！**

---

## ✨ 核心特性

- ⚡ **零带宽消耗**：基于 AList 异步复制流，数据不走本地服务器，千兆对撞。
- 📅 **智能动态跨年**：自动注入 Linux `$(date +%Y)` 变量，一次配置，终身自动跟随 2026、2027... 跨年跨月不挂科。
- 🧩 **全自动增量**：AList 底层机制遇到同名文件自动跳过，只搬运每天新生成的 WebP/动图，省心高效。
- 📝 **全量日志留痕**：自动向 `/tmp/alist_sync.log` 吐出审计日志，出错一秒破案。

---

## 🛠️ 前置准备

1. **环境**：任意 Linux VPS (在 Debian/Ubuntu 下完美通过)。
2. **AList 挂载**：确保你的源盘 (如 Cloudflare R2) 和目标盘 (如 Google Drive) 已稳稳挂载在 AList 的存储列表里。
3. **获取令牌**：登录 AList 后台 -> `设置` -> `全局` -> 复制你的 **`令牌 (Token)`**。

---

## 📦 部署方案（二选一）

### 💡 方案 A：极致极简 crontab 一枪通电流（最推荐 🌟）

如果你网速拉满，懒得在服务器里单独塞个 `.sh` 文件，可以直接利用 crontab 的原生注入。
直接在 VPS 终端输入 `crontab -e`，并把下面这一整行塞到最底部即可：

```bash
0 3 * * * curl -X POST "[http://127.0.0.1:5244/api/fs/copy](http://127.0.0.1:5244/api/fs/copy)" -H "Authorization: 你的AListToken" -H "Content-Type: application/json" -d '{"src_dir": "/Cloudflare-R2/img", "dst_dir": "/google-drive/google/图床", "names": [""'$(date +\%Y)'""]}' >> /tmp/alist_sync.log 2>&1
```

> ⚠️ **Crontab 避坑神仙提醒**：
> 在 crontab 底层环境中，百分号 `%` 属于特殊终止符。如果是写在 crontab 一行流里，必须写成 `\%Y`（带反斜杠转义），否则脚本会直接死锁。本行命令已完美闭环此大坑！

---

### 💻 方案 B：传统脚本流（适合需要本地调测的老哥）

1. 在你的 VPS 上新建一个 `sync.sh` 脚本，内容如下：

```bash
#!/bin/bash
# --- ⚙️ 核心参数配置区域 ---
ALIST_URL="[http://127.0.0.1:5244](http://127.0.0.1:5244)"   # 你的 AList 访问地址
ALIST_TOKEN="填写你的AList全局Token" # AList 全局 Token
SRC_DIR="/Cloudflare-R2/img"        # AList 源盘图床根目录
DST_DIR="/google-drive/google/图床" # AList 目标云盘备份目录

# --- 🚀 核心自动化逻辑 ---
CURRENT_YEAR=$(date +%Y)
LOG_FILE="/tmp/alist_sync.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🚀 开始多云对撞同步任务..." >> $LOG_FILE
RESPONSE=$(curl -s -X POST "${ALIST_URL}/api/fs/copy" \
  -H "Authorization: ${ALIST_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"src_dir\": \"${SRC_DIR}\", \"dst_dir\": \"${DST_DIR}\", \"names\": [\"${CURRENT_YEAR}\"]}")

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎯 AList 核心响应: ${RESPONSE}" >> $LOG_FILE
```

2. 赋予执行权限并挂载定时任务：
   ```bash
   chmod +x sync.sh
   crontab -e
   ```
   在底部添加：
   ```bash
   0 3 * * * /bin/bash /path/to/sync.sh
   ```

---

## 📊 日志审计与排错

任务自动在每天凌晨 3:00 运行，你可以随时去查看同步状态：
```bash
cat /tmp/alist_sync.log
```

**正常通电的响应示例：**
```text
[2026-05-23 03:00:00] 🚀 开始多云对撞同步任务...
[2026-05-23 03:00:00] 📅 目标同步年份目录: 2026
[2026-05-23 03:00:01] 🎯 AList 核心响应: {"code":200,"message":"success","data":null}
```
返回 `code: 200` 即代表传输指令已成功下发至 AList 后台异步对撞执行！

---

## 📄 许可证与免责声明

本项目基于 **[MIT License](LICENSE)** 协议开源。
你可以自由复制、修改、分发及用于商业用途，但请保留原作者署名。作者不对因使用本脚本导致的任何形式的数据丢失、服务器故障或云服务商账单超支承担任何法律责任。请在生产环境部署前做好充分测试。

