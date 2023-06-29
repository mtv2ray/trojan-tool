#!/bin/bash
TROJAN_GO_VERSION_CHECK="https://api.github.com/repos/p4gefau1t/trojan-go/releases"
MAINASSET="https://raw.githubusercontent.com/mtv2ray/trojan-tool/main"
DOMAIN_NAME="tvpn1.y7srvahawg.top"

#######color code########
RED="31m"
GREEN="32m"
YELLOW="33m"
BLUE="36m"
FUCHSIA="35m"

colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

# TROJAN_GO_LASTEST_VERSION=$(curl -H 'Cache-Control: no-cache' -s "$TROJAN_GO_VERSION_CHECK" | grep 'tag_name' | cut -d\" -f4)

# curl -L https://get.acme.sh -o acme.sh
# echo "下载acme.sh脚本"

# rm acme.sh
# echo "为了使acme.sh脚本总是最新的用完就删"

checkSys(){
    #检查是否为Root
    [ $(id -u) != "0" ] && { colorEcho ${RED} "Error: You must be root to run this script"; return 0; }
    ARCH=$(uname -m 2> /dev/null)
    if [[ $ARCH != x86_64 && $ARCH != aarch64 ]];then
        colorEcho $YELLOW "not support $ARCH machine".
        return 0
    fi
    if [[ `command -v apt-get` ]];then
        PACKAGE_MANAGER='apt-get'
    elif [[ `command -v dnf` ]];then
        PACKAGE_MANAGER='dnf'
    elif [[ `command -v yum` ]];then
        PACKAGE_MANAGER='yum'
    else
        colorEcho $RED "Not support OS!"
        return 0
    fi
    if [[ -z `command -v unzip` ]];then
        ${PACKAGE_MANAGER} install unzip -y
    fi
    if [[ -z `command -v jq` ]];then
        ${PACKAGE_MANAGER} install jq -y
    fi
}

getLoaclIp(){
    loaclip=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
}

# getTrojanServerJson(){
#     curl -o "$MAINASSET/tvpn1.y7srvahawg.top"
# }

acme(){
    curl -L https://get.acme.sh -o acme.sh
    echo "下载acme.sh脚本"

    rm acme.sh
    echo "为了使acme.sh脚本总是最新的用完就删"
}

main(){
    checkSys
    if [ $? != 0 ];then
        echo "hello"
    fi
    getLoaclIp
    echo "hello $loaclip"
    # getTrojanServerJson
    # acme
    # cat n.json | jq -r '.metadata.namespace'
}

main