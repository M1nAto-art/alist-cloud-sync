#!/bin/bash
# =======================================================================
# Description: AList 多云存储全自动定时增量对撞同步脚本 (支持动态跨年跨月)
# Author: M1nAt0
# Repo: https://github.com/M1nato-art/alist-cloud-sync
# =======================================================================

# --- ⚙️ 核心参数配置区域 ---
ALIST_URL="http://127.0.0.1:5244"   # AList 访问地址 (如果在 VPS 本地，保持默认即可)
ALIST_TOKEN="填写你的AList全局Token" # AList 后台 -> 设置 -> 全局 获取的 Token
SRC_DIR="/Cloudflare-R2/img"        # AList 中挂载的源盘目录 (图床根目录)
DST_DIR="/google-drive/google/图床" # AList 中挂载的目标云盘备份目录

# --- 🚀 核心自动化逻辑 (无需修改) ---
CURRENT_YEAR=$(date +%Y)
LOG_FILE="/tmp/alist_sync.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🚀 开始多云对撞同步任务..." >> $LOG_FILE
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 📅 目标同步年份目录: ${CURRENT_YEAR}" >> $LOG_FILE

# 调用 AList 官方 API 进行后台异步复制
RESPONSE=$(curl -s -X POST "${ALIST_URL}/api/fs/copy" \
  -H "Authorization: ${ALIST_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"src_dir\": \"${SRC_DIR}\", \"dst_dir\": \"${DST_DIR}\", \"names\": [\"${CURRENT_YEAR}\"]}")

# 日志审计
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎯 AList 核心响应: ${RESPONSE}" >> $LOG_FILE
echo "------------------------------------------------------------" >> $LOG_FILE
