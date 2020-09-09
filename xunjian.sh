#!/bin/bash
#author:wenxiaoyang
#date:2019/09/23
#显示日常巡检信息，日志内容需要自己去查看
#此脚本需要根据不同服务器选择不同模块使用
#71服务器上的脚本是第一版，个别情况不准确
#jdk1.7启动程序老年代内存占用
java7_old(){
	local PID=$1
	local OLDUSE=`jstat -gc $PID|awk '{if(NR==2){print($8)}}'|awk -F. '{print($1)}'`
	local OLDMAX=`jstat -gccapacity $PID|awk '{if(NR==2){print($8)}}'|awk -F. '{print($1)}'`
	return $(($OLDUSE*100/$OLDMAX))
}

#jdk1.7启动程序持久代内存占用
java7_per(){
	local PID=$1
	local PERUSE=`jstat -gc $PID|awk '{if(NR==2){print($10)}}'|awk -F. '{print($1)}'`
	local PERMAX=`jstat -gccapacity $PID|awk '{if(NR==2){print($12)}}'|awk -F. '{print($1)}'`
	return $(($PERUSE*100/$PERMAX))
}

#jdk1.8启动程序老年代内存占用
java8_old(){
	local pid=$1
	local OLDUSE=`/opt/jdk1.8.0_45/bin/jstat -gc $pid|awk '{if(NR==2){print($8)}}'|awk -F. '{print($1)}'`
	local OLDMAX=`/opt/jdk1.8.0_45/bin/jstat -gccapacity $pid|awk '{if(NR==2){print($8)}}'|awk -F. '{print($1)}'`
	return $(($OLDUSE*100/$OLDMAX))
}

#jdk1.8启动程序元数据空间内存占用
java8_per(){
	local pid=$1
	local METUSE=`/opt/jdk1.8.0_45/bin/jstat -gc $pid|awk '{if(NR==2){print($10)}}'|awk -F. '{print($1)}'`
	local METMAX=`/opt/jdk1.8.0_45/bin/jstat -gccapacity $pid|awk '{if(NR==2){print($12)}}'|awk -F. '{print($1)}'`
	return $(($METUSE*100/$METMAX))
}


#磁盘使用情况
disk(){
	gen=`df -h | grep  '\/$'|awk '{print $5}'|sed 's/%//'`
	home=`df -h | grep  'home$'|awk '{print $5}'`
	#echo "磁盘使用情况："
	if [ -z  $home ];then
		#echo "  根分区目录已使用$gen"
		:
	else
		#echo "  根分区目录已使用$gen"
		#echo "  home目录已使用$home"
		#echo "--------------------------------------------------------------------------"
		:
	fi
	#echo "--------------------"
	if [ $gen -gt 90      ];then
		#echo -e '磁盘容量\tX'
		printf "%-20s\t%-s\n" 磁盘容量 X
	else
		#echo -e '磁盘容量\t√'
		printf "%-20s\t%-s\n" 磁盘容量 √
	fi
}

#内存使用情况
mem(){
	#echo "内存使用情况："
	neicun=`free -m|awk '/Mem/{print($3/$2*100)}'|awk -F. '{print $1}'`
	#echo "  内存已使用${neicun:0:5}%"
	#echo "--------------------"
	#echo $neicun
	if [  $neicun -gt 90    ];then
		#echo -e '内存\t\tX'
		printf "%-20s\t%-s\n" 内存 X
	else
		#echo -e '内存\t\t√'
		printf "%-20s\t%-s\n" 内存 √
	fi
}

#cpu使用情况
#cpu使用率是实时变化的，以查看时取到的数值为准
cpu(){
	#echo "cpu使用情况："
	cpur=`vmstat | awk '/3/{printf($13"\n")}'`
	#echo "  内存使用率是$cpur%"
	#echo "--------------------"
	#echo $cpur
	if  [ $cpur -gt 90   ];then
		#echo -e 'CPU\t\tX'
		printf "%-20s\t%-s\n" CPU X
	else
		#echo -e 'CPU\t\t√'
		 printf "%-20s\t%-s\n" CPU √
	fi
}
port_select(){

case $1 in 
tomcat)
	port=8080
	java_version=7
	;;
bpm)
	port=8084
	java_version=7
	;;
bpm_server)
	port=8091
	java_version=8
	;;
bpm_application)
	port=8013
	java_version=8
	;;
bpm_server_new)
	port=8092
	java_version=8
	;;
xxfb)
	port=8029
	java_version=7
	;;
yw)
	port=8011
	java_version=8
	;;
yw_new)
	port=8010
	java_version=8
	;;
app22)
	port=8012
	java_version=8
	;;
app24)
	port=8013
	java_version=8
	;;
chat)
	port=7001
	java_version=8
	;;
chat_service)
	port=9323
	java_version=8
	;;
bpm_dj)
	port=8085
	java_version=8
	;;
bpm_server_dj)
	port=8093
	java_version=8
	;;
dj)
	port=8083
	java_version=8
	;;
fmapp)
	port=8082
	java_version=8
	;;
bpm_server_fmapp)
	port=8014
	java_version=8
	;;
esac


}
control(){
	#echo "${1}情况"
	port_select $1
	pid=`ss -ntpl|awk "/:${port} /{print $6};"|sed 's/.*pid=\(.*\),.*/\1/'`
	        if [ -z ${pid} ];then
               #echo -e "  \033[31m ${1}进程未启动 \033[0m"
		printf "%-20s\t%-s\n" ${1}进程 X
        else    
                java${java_version}_old $pid
                old=$?
                java${java_version}_per $pid
                per=$?
                p_num=`ls  /proc/$pid/task|wc -w`
                #echo "  ${1}进程启动正常,进程ID:$pid"
		#echo -e "${1}进程\t√"
		printf "%-20s\t%-s\n" ${1}进程 √
                #echo "  ${1}_jvm内存占用：老年代 $old%,持久代 $per%"
		if [ $per -gt 90    ];then
			#echo -e "${1}内存\tX"
			printf "%-20s\t%-s\n" ${1}内存 X
		else
			#echo -e "${1}内存\t√"
			printf "%-20s\t%-s\n" ${1}内存 √
		fi
                #echo "  ${1}启用线程数$(($p_num))"
		#echo -e "${1}线程数\t${p_num}"
		printf "%-20s\t%-s\n" ${1}线程数 ${p_num}
        fi
        #echo "--------------------"

}
main(){
disk
mem
cpu
echo '-----------------------------------------------黄金分割--------------------------------------------------------------'
control tomcat
control bpm_application
control bpm_server
control xxfb
control dj
control yw
}
main
