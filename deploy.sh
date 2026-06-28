#!/bin/bash

# スクリプトの場所を基準にディレクトリを移動
cd "$(dirname "$0")"

# 1. .env ファイルの読み込み
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from ${ENV_FILE}..."
    # export をつけて source することで、子プロセスやコマンド置換内でも変数を利用可能にする
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "Error: ${ENV_FILE} file not found." >&2
    exit 1
fi

# 2. 必須変数のバリデーション
if [ -z "$ROUTER_IP" ] || [ -z "$SLACK_URL" ]; then
    echo "Error: ROUTER_IP or SLACK_URL is not set in ${ENV_FILE}." >&2
    exit 1
fi

# デフォルト値の設定（.envで未指定の場合）
TARGET_FILENAME="${TARGET_FILENAME:-sip_logger.lua}"
TMP_FILE="sip_logger_generated.lua"
TEMPLATE_FILE="src/sip_logger.lua.tmpl"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file ${TEMPLATE_FILE} not found." >&2
    exit 1
fi

echo "----------------------------------------"
echo "Target Router : ${ROUTER_IP}"
echo "Target File   : /${TARGET_FILENAME}"
echo "----------------------------------------"

# 3. テンプレート内のプレースホルダーを置換
echo "Generating Lua script from template..."
sed "s|{{SLACK_WEBHOOK_URL}}|${SLACK_URL}|g" "$TEMPLATE_FILE" > "$TMP_FILE"

# 4. ルータへTFTPで転送
echo "Uploading to YAMAHA Router via TFTP..."
tftp "$ROUTER_IP" <<EOS
mode octet
put ${TMP_FILE} /${TARGET_FILENAME}
quit
EOS

# 5. 後処理
rm "$TMP_FILE"
echo "Deployment successfully completed for ${ROUTER_IP}."
