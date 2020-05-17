#!/usr/bin/env bash
#version 1.0 by bai 7 may 2020
#bilibili bohezhongjiushixinliang


function get_char()
{
SAVEDSTTY=`stty -g`
stty -echo 
stty cbreak            
dd if=/dev/tty bs=1 count=1 2> /dev/null        
stty -raw                                     
stty echo                                   
stty $SAVEDSTTY             
}

ubuntu(){
	sudo cp -r /etc/apt/sources.list /etc/apt/sources.list.bak  &> /dev/null
	sudo sed -i "s/\/\/.*archive.ubuntu.com/\/\/mirrors.aliyun.com/g;s/\/\/.*security.ubuntu.com/\/\/mirrors.aliyun.com/g" /etc/apt/sources.list
	ubuntu_num=`grep "aliyun"  /etc/apt/sources.list |wc -l`
	if [ $ubuntu_num -ne 0   ];then
		echo "换源成功"
	else
		echo "换源失败了？？？"
	fi
 }




test_os_version(){
if [  ! -f /etc/redhat-release      ];then
	echo "检测到您的系统为debian系系统"
	echo "按任意键开始换源(ctrl+c退出脚本)"
	get_char
	echo "正在为您换源……"
	ubuntu
	exit
fi
}





test_root(){
if [ `id -u` -ne 0      ];then
	echo "本脚本需要在root环境下进行,正在退出……"
	echo "请切换成root用户，或者使用sudo命令"
	exit
fi

}
OS=`uname -r|awk -F"." '{print $4}'|sed 's/el//'`
machine=`uname -m`


menu(){
menu_action=""
cat <<-EOF
-----------------------------------------
|               一键换源工具            |
|       1.更换基础源                    |
|       2.更换国内epel源                |
|       3.更换国内zabbix源              |
|       4.更换国内mariadb源             |
|       5.显示本菜单    		|
|	6.退出程序	                |
-----------------------------------------
EOF
read -p "请输入您要执行的选项[按h显示本菜单]： " menu_action
}

base(){
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup &> /dev/null
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-${OS}.repo & >/dev/null
if [ $? -eq 0     ];then
        echo "太棒了，配置成功"
	sleep 2
else
        echo "好像失败了，待会儿再试，或者联系作者"
        exit
fi
echo "按任意键缓存新的源"
get_char
echo "正在缓存新的源……"
yum clean all
yum makecache


}

epel(){
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup &> /dev/null
mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup &> /dev/null


curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-${OS}.repo
if [ $? -eq 0     ];then
        echo "太棒了，配置成功"
	sleep 2
else
        echo "好像失败了，待会儿再试，或者联系作者"
        exit
fi
echo "按任意键缓存新的源"
get_char
echo "正在缓存新的源……"
yum clean all
yum makecache



}
zabbix(){
mv /etc/yum.repos.d/zabbix.repo /etc/yum.repos.d/zabbix.repo.backup &> /dev/null
cat > /etc/yum.repos.d/zabbix.repo <<-EOF 
[zabbix]
name=Zabbix Official Repository 
baseurl=http://mirrors.aliyun.com/zabbix/zabbix/4.4/rhel/${OS}/$machine/
enabled=1
gpgcheck=0


EOF
key_num=`grep 'aliyun' /etc/yum.repos.d/zabbix.repo |wc -l`

if [  $key_num -ne 0   ];then
	echo "太棒了，配置成功"
else
	echo "好像失败了，待会儿再试，或者联系作者"
	exit
fi
echo "按任意键缓存新的源"
get_char
echo "正在缓存新的源……"
yum clean all
yum makecache
}
mariadb(){
mv /etc/yum.repos.d/mariadb.repo /etc/yum.repos.d/mariadb.repo.backup &> /dev/null
cat > /etc/yum.repos.d/mariadb.repo <<-EOF 
# MariaDB 10.4 CentOS repository list - created 2019-09-21 06:58 UTC 
# http://downloads.mariadb.org/mariadb/repositories/ 
[mariadb] 
name = MariaDB 
baseurl = https://mirrors.aliyun.com/mariadb/yum/10.4/centos${OS}-amd64 
gpgkey = https://mirrors.aliyun.com/mariadb/yum/RPM-GPG-KEY-MariaDB 
gpgcheck = 1

EOF
if [ -f /etc/yum.repos.d/mariadb.repo   ];then
        echo "太棒了，配置成功"
else
        echo "好像失败了，待会儿再试，或者联系作者"
    exit
fi
echo "按任意键缓存新的源"
get_char
echo "正在缓存新的源……"
yum clean all
yum makecache


}
case_sel(){
while :
do
case $menu_action in
1)
	base
	echo "缓存完成，按任意键回主菜单"
	get_char
	menu_action=h
	;;
2)
	epel
       echo "缓存完成，按任意键回主菜单"
        get_char
	menu_action=h	
	;;	
3)
	zabbix
       echo "缓存完成，按任意键回主菜单"
        get_char
	menu_action=h
	;;
4)
	mariadb
       echo "缓存完成，按任意键回主菜单"
        get_char
	menu_action=h
	;;
5|h)
	clear
	menu	
	;;
6|q)
	exit
	;;
*)
	echo "输入错误，我死掉了……"
	exit
	;;


esac


done

}

main(){
test_root
test_os_version
menu
case_sel
}
main

