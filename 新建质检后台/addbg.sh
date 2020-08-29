#/usr/bin/env bash
old_dir=zlt
read -p '请输入新的后台名称：' bs_name
#echo $bs_name
read -p '请输入新的后台端口：' bs_port
#echo $bs_port


main() {
#复制一份文件夹
cp -rp ${old_dir} ${bs_name}

#进入新的文件夹
cd ${bs_name}

#更改配置文件中名称
sed -i 's/'"${old_dir}"'/'"${bs_name}"'/g' application.properties

#更改配置文件中端口
sed -i  '/^server.port=/s/[0-9]\{4\}/'"${bs_port}"'/' application.properties

#修改文件名称
mv application-${old_dir}.properties application-${bs_name}.properties

#修改Dockerfile中的名字
sed -i  's/'"${old_dir}"'/'"${bs_name}"'/g' Dockerfile

#修改两个脚本名字和端口
#名字
sed -i  's/'"${old_dir}"'/'"${bs_name}"'/g' *.sh
#端口
sed -i  's/[0-9]\{4\}:[0-9]\{4\}/'"${bs_port}"':'"${bs_port}"'/g' *.sh
}

clear
cat <<-EOF
------------------------------------------------------------------------
		您输入的后台名称是：${bs_name}
		您输入的后台端口是: ${bs_port}
------------------------------------------------------------------------
EOF

read -p '确认无误!输入y继续执行：' action
if [  ${action} = y  ];then
	main
else
echo '取消了'
exit 1
fi
#exit 1 用户取消
#main
#pwd
if [ -d ../${bs_name}   ];then
echo '成功建立新后台'
else
echo '失败了吧，咱也不知道，咱也不敢问'
exit 2
fi
#exit 2 文件夹建立失败
