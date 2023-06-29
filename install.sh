#!/bin/bash
CLEARTMP=0 # 0 清空tmp 1 不清空
TROJAN_GO_VERSION_CHECK="https://api.github.com/repos/p4gefau1t/trojan-go/releases"
MAINASSET="https://raw.githubusercontent.com/mtv2ray/trojan-tool/main"
DOMAIN_NAME="tvpn1.y7srvahawg.top"
TMPTROJAN_GO="/tmp/trojan-go"
NAME=trojan-go
SERVICE_NAME="trojan-go@.service"

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
    #检查443端口是否占用
    # webpid=`lsof -i :443 | awk '{print $1 " " $2}'`
    # if [ "$webpid" == "" ];then
    #     colorEcho ${RED} "Error: port 443 is in use!";
    #     return 0;
    # fi
    
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

    if [[ ! -z `command -v python3` ]];then
        PYTHON_MANAGER='python3'
    elif [[ ! -z `command -v python2` ]];then
        PYTHON_MANAGER='python2'
    elif [[ ! -z `command -v python` ]];then
        PYTHON_MANAGER='python'
    elif [[ -z `command -v python3` ]];then
        ${PACKAGE_MANAGER} install python3 -y
        PYTHON_MANAGER='python3'
    elif [[ -z `command -v python2` ]];then
        ${PACKAGE_MANAGER} install python2 -y
        PYTHON_MANAGER='python2'
    elif [[ -z `command -v python` ]];then
        ${PACKAGE_MANAGER} install python -y
        PYTHON_MANAGER='python'
    fi
    if [ CLEARTMP != 1 ];then
        echo "清空 $TMPTROJAN_GO 缓存目录"
        rm -rf ${TMPTROJAN_GO}
        rm /tmp/$TARBALL
    fi
    if [ ! -d /var/log ];then
        mkdir /var/log
    fi
    if [ ! -d "$TMPTROJAN_GO" ];then
        echo "生成 $TMPTROJAN_GO 缓存目录"
        mkdir ${TMPTROJAN_GO}
    fi
}

getLoaclIp(){
    echo "获取公网ip"
    # loaclip=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
    loaclip=$(curl ifconfig.me)
}

getTrojanServerJson(){
    if [ ! -f "$TMPTROJAN_GO/server.json" ];then
        curl -o "$TMPTROJAN_GO/server.json" "$MAINASSET/$DOMAIN_NAME.json"
    fi
}

pythonweb(){
    webpid=`lsof -i :80 | awk '{print $1 " " $2}'`
    if [ "$webpid" == "" ];then
        curl -o "$TMPTROJAN_GO/server.py" "$MAINASSET/server.py"
        chmod +x "$TMPTROJAN_GO/server.py"
        nohup ${PYTHON_MANAGER} "$TMPTROJAN_GO/server.py" >/var/log/trojan_http.log 2>&1 &
    fi
    # webpids=`lsof -i :443 | awk '{print $1 " " $2}'`
    # if [ "$webpid" == "" ];then
    #     curl -o "$TMPTROJAN_GO/serverHttps.py" "$MAINASSET/serverHttps.py"
    #     chmod +x "$TMPTROJAN_GO/serverHttps.py"
    #     nohup ${PYTHON_MANAGER} "$TMPTROJAN_GO/serverHttps.py" >/var/log/trojan_https.log 2>&1 &
    # fi
}

acme(){
    acmeCertPath=$(cat "$TMPTROJAN_GO/server.json" | jq -r '.ssl.cert')
    acmeKeyPath=$(cat "$TMPTROJAN_GO/server.json" | jq -r '.ssl.key')
    acmeServer=$(cat "$TMPTROJAN_GO/server.json" | jq -r '.ssl.sni')
    if [ CLEARTMP != 1 ];then
        rm $acmeCertPath
        rm $acmeKeyPath
    fi
    if [ ! -f $acmeCertPath ] || [ ! -f $acmeKeyPath ];then
        acmeCertPathDir=$(dirname "$acmeCertPath") 
        acmeKeyPathDir=$(dirname "$acmeKeyPath")
        if [ ! -f $acmeCertPathDir ];then
            echo "$acmeCertPathDir"
            mkdir -p $acmeCertPathDir
        fi
         if [ ! -f $acmeKeyPathDir ];then
            echo "$acmeKeyPathDir"
            mkdir -p $acmeKeyPathDir
        fi
        echo "需要生成新证书"
        echo "执行acme.sh"
        if [ ! -f "/root/.acme.sh/acme.sh" ] || [ CLEARTMP != 1 ];then
            curl https://get.acme.sh | sh -s email=yuuhaha@gmail.com
        else
            /root/.acme.sh/acme.sh --upgrade
        fi 
        
        /root/.acme.sh/acme.sh --issue -d $acmeServer --debug --standalone --keylength ec-256 --force 
        # /root/.acme.sh/acme.sh --issue -d $acmeServer --debug --standalone --keylength ec-256 --force --server $loaclip
        cp /root/.acme.sh/${acmeServer}_ecc/fullchain.cer $acmeCertPath
        cp /root/.acme.sh/${acmeServer}_ecc/$acmeServer.key $acmeKeyPath
    fi
}

installTrojanGO(){
    if [ ! -f /tmp/$TARBALL ];then
        VERSION=$(curl -H 'Cache-Control: no-cache' -s "$TROJAN_GO_VERSION_CHECK" | grep 'tag_name' | cut -d\" -f4 | sed 's/v//g' | head -n 1)
        TARBALL="trojan-go-linux-amd64.zip"
        DOWNLOADURL="https://github.com/p4gefau1t/trojan-go/releases/download/v$VERSION/$TARBALL"
        echo Downloading $NAME $VERSION url $DOWNLOADURL ...
        wget -q --show-progress "$DOWNLOADURL" -P /tmp/
    fi

    echo Unpacking $NAME $VERSION...
    unzip -o /tmp/$TARBALL -d /tmp/$NAME
    echo Unpack Done $NAME $VERSION...
    mv -f /tmp/$NAME/trojan-go /usr/bin
    if [ ! -d /etc/$NAME ];then
        mkdir /etc/$NAME 
    fi
    cp $TMPTROJAN_GO/server.json /etc/$NAME/server.json
    cp $TMPTROJAN_GO/geoip.dat /etc/$NAME/geoip.datcd 
    cp $TMPTROJAN_GO/geosite.dat /etc/$NAME/geosite.dat
    if [ ! -f $TMPTROJAN_GO/$SERVICE_NAME ];then
        curl -o "$TMPTROJAN_GO/$SERVICE_NAME" "$MAINASSET/$SERVICE_NAME"
    fi
    cp $TMPTROJAN_GO/$SERVICE_NAME /etc/systemd/system
    systemctl daemon-reload
    systemctl enable trojan-go@server.service
    systemctl start trojan-go@server.service
    systemctl status trojan-go@server.service
    # systemctl stop trojan-go@server.service
}

main(){
    checkSys
    if [ $? != 0 ];then
        colorEcho ${RED} "失败"
    fi
    # echo "获取公网ip"
    # getLoaclIp
    # echo "公网ip: $loaclip"
    getTrojanServerJson
    
    acme
    pythonweb
    installTrojanGO
}

main