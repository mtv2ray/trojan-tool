#!/bin/bash
 DOMAIN_NAME="tvpn1.y7srvahawg.top"
if [ "$1" != "" ];then
    DOMAIN_NAME="$1"
fi
echo "$DOMAIN_NAME"

MAINASSET="https://raw.githubusercontent.com/mtv2ray/trojan-tool/main"
curl -o "$DOMAIN_NAME.json.doc" "$MAINASSET/sspanel.json"
sed "s/{DOMAIN}/$DOMAIN_NAME/g" "$DOMAIN_NAME.json.doc" > "$DOMAIN_NAME.json"