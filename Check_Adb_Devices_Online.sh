#!/bin/bash
nohup node /root/ws-scrcpy/index.js > /dev/null 2>&1 &
# 检查进程端口是否存在
sleep 30
nc -zv 127.0.0.1:8000
if [ $? == 0 ]; then
    echo "进程端口8000正常" $(date +%F) $(date +%T)
 else
    echo "进程端口8000异常,退出运行" $(date +%F) $(date +%T)
    sleep 5
    exit 1
fi    
cd /root/ws-scrcpy

# 创建在线文件
if [ -e "adbonline.log" ]; then
    echo "adbonline.log文件存在" $(date +%F) $(date +%T)
else
    echo "adbonline.log文件不存在,新建此文件" $(date +%F) $(date +%T)
    touch adbonline.log
fi

# 是否自动重连
if [ "$AUTO_CONNECT" = "true" ]; then
    echo "开启自动重连模式" $(date +%F) $(date +%T)
    sleep 20
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
            	if [ "$?" == 0 ]; then
            		echo "网络正常,开始链接: " "$current_line" $(date +%F) $(date +%T)
        			adb connect "$current_line":5555
                else
                    echo "网络异常,不进行链接~" $(date +%F) $(date +%T)
        		fi	
    		else
        		echo "无在线设备，不管他" $(date +%F) $(date +%T)
    		fi
    		sleep 10
        done < adbonline.log
        sleep 30
    done
else
    while true
    do
        echo "关闭自动重连模式" $(date +%F) $(date +%T)
        sleep 3600
    done
fi
