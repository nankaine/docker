#!/bin/bash
nohup node /root/ws-scrcpy/dist/index.js > /dev/null 2>&1 &
cd /root/ws-scrcpy

# 创建在线文件
if [ -e "adbonline.log" ]; then
    echo "adbonline.log文件存在"
else
    echo "adbonline.log文件不存在,新建此文件"
    touch adbonline.log
fi

# 无限循环
while true
do
	adb devices | grep device | grep -v devices | awk -F':' '{print $1}' > adbonline.log
    # 使用 while 循环和 read 命令逐行读取文件
    while IFS= read -r line
    do
        # 将当前行赋值给变量
        current_line="$line"
        
        if [ -n "$current_line" ]; then
        	ping -q -c 10 "$current_line"
        	if [ $? == 0 ]; then
        		echo "网络正常,开始链接: " "$current_line"
    			adb connect "$current_line":5555
            else
                echo "网络异常,不进行链接~"
    		fi	
		else
    		echo "无在线设备，不管他"
		fi
		sleep 10
    done < adbonline.log
    sleep 30
done