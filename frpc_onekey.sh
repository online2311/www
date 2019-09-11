#!/bin/bash
 
green='\e[1;32m' # green
red='\e[1;31m' # red
blue='\e[1;34m' # blue  
nc='\e[0m' # normal
clear
 
download(){
    echo -n "下载FRP . . ."
    sleep 0.3 
    echo -n "."
    mkdir /etc/frp
    wget -O /etc/frp/frp.tar.gz $1
    if [ $? == 0 ] ; then
        echo -e "[${green}成功${nc}]"
    else
        echo -e "[${red}失败${nc}]"
        exit 1
    fi
}
 
install(){
    echo -n "Installing Frp . . ."
    pcd=`pwd`
    cd /etc/frp/
    sleep 0.3
    echo -n "."
    tar zxf /etc/frp/frp.tar.gz 
    if [ $? == 0 ] ; then
        echo -e "[${green}成功${nc}]"
    else
        echo -e "[${red}失败${nc}]"
        exit 1
    fi
    rm -f /etc/frp/frp.tar.gz
    mv frp_0.* frp-config
    cd $pcd
}
 
cat << EOF
=========================================================================
欢迎使用FRP内网映射脚本
=========================================================================
版本更新：更新启动脚本功能
客户端版本:0.20.0
=========================================================================
USER: $USER   HOST: $HOSTNAME  KERNEL: `uname -r`  
DISK :`ls  /dev/?d? 2>/dev/null`
你确定要安装吗？【Y/y】
EOF
config(){
    echo -n "设置FRP Frp . . ."
    pcd=`pwd`
    cd /etc/frp/frp-config
    sleep 0.3
    echo -n "."
    rm -f frpc.ini
    touch frpc.ini
    HOST_IP=$(curl icanhazip.com)

    read -p  "请输入FRP服务端密码:[PassWord]" password
    if [ ! $password ] ;then
        password=PassWord
    fi
    read -p  "请输入FRP服务端域名:[47.105.54.145]" IP
    if [ ! $IP ] ;then
        IP=47.105.54.145
    fi
    read -p  "请输入本地IP:[127.0.0.1]" Local
    if [ ! $Local ] ;then
        Local=127.0.0.1
    fi
     
cat > frpc.ini <<EOF
[common]
server_addr = $IP
server_port = 443
log_file = ./frpc.log
log_level = info
log_max_days = 3
token = $password
protocol = kcp


[$HOST_IP.SSH]
type = tcp
remote_port = 0
local_ip = $Local
local_port = 22
use_gzip = true use_encrypti
EOF
 
sudo cat > /etc/init.d/frp <<EOF
#!/bin/bash
# chkconfig: - 99 2
# description: FRP Client Control Script
PIDF=\` ps  -A | grep frpc | awk '{print \$1}'\`
case "\$1" in
        start)
        nohup /etc/frp/frp-config/frpc -c /etc/frp/frp-config/frpc.ini >/dev/null 2>&1  &
        ;;
        stop)
        kill -3  \$PIDF
        ;;
        restart)
        \$0 stop &> /dev/null
        if [ \$? -ne 0 ] ; then continue ; fi
        \$0 start
        ;;
        reload)
        kill -1 \$PIDF
        ;;
    status)
    cat /frpc.log
    ;;
        *)
        echo "Userage: \$0 { start | stop | restart | reload | status }"
        exit 1
esac
exit 0
 
EOF
 
 
chmod +x /etc/init.d/frp
 
    if [ $? == 0 ] ; then
        echo -e "[${green}成功${nc}]"
    else
        echo -e "[${red}失败${nc}]"
        exit 1
    fi
    cd $pcd
}
 
 
 
read -p "请输入Y/y确定安装" key
case $key in
    "y"|"Y"|"")     
        cat << EOF
请输入你的Linux系统类型:
(1)X86          (2)X64
(3)ARM、树莓派      (4)Mitps
(5)Mitps64      (6)Mitpsle
(7)Mitps64le 
(8) 如果已经下载好了FRP 
    请将下载好的文件保存到/etc/frp下
    并重命名为frp.tar.gz
 
EOF
        read -p "请输入序号:" key
        case $key in
            1)
                download https://github.com/fatedier/frp/releases/download/v0.20.0/frp_0.20.0_linux_386.tar.gz
            ;;
            2)
                download https://github.com/fatedier/frp/releases/download/v0.20.0/frp_0.20.0_linux_amd64.tar.gz
            ;;
            3)  
                download https://github.com/fatedier/frp/releases/download/v0.20.0/frp_0.20.0_linux_arm.tar.gz
            ;;
            4)
                download https://github.com/fatedier/frp/releases/download/v0.20.0/frp_0.20.0_linux_mips.tar.gz
            ;;
            5)
                download https://github.com/fatedier/frp/releases/download/v0.20.0/frp_0.20.0_linux_mips64.tar.gz
            ;;
            6)
                download https://github.com/fatedier/frp/releases/download/v0.20.0/frp_0.20.0_linux_mipsle.tar.gz
            ;;
            7)
                download https://github.com/fatedier/frp/releases/download/v0.20.0/frp_0.20.0_linux_mips64le.tar.gz
            ;;
            8)
                echo "OK"
            ;;
            *)
                exit
            ;;
            esac
            install
            config
            result=$?
            echo -n "FRP客户端安装结果  .."
            if [ $result == 0 ] ; then
                echo -e "[${green}成功${nc}]"
                echo "Enjoy~"
                sleep 1
                echo "你可以通过: \"service frp start\" 命令去启动FRP"
                echo "通过\"chkconfig frp on\" 设置FRP开机启动"
                echo "FRP 配置文件路径 /etc/frp/frp-config/frpc.ini"
                echo "通过 \"service frp status\"查看frp工作状态"
                sleep 1
                exit
            else
                echo -e "[${red}失败${nc}]"
                exit 1
            fi
    ;;
    *)
    exit
    ;;
esac

