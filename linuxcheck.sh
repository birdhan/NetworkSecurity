echo ""
echo " ========================================================= "
echo "                   Linux应急响应信息搜集脚本               "
echo " ========================================================= "
echo " # author：Rock      "
echo ""
echo -e "\e[00;32m[+]系统信息\e[00m"
echo -e "\n"
#当前用户
echo -e "当前用户:\t" $(whoami) 2>/dev/null
#版本信息
echo -e "系统版本:\t" $(cat /etc/redhat-release)
#主机名
echo -e "主机名称: \t" $(hostname -s)
#uptime
echo -e "uptime: \t" $(uptime | awk -F ',' '{print $1}')
echo -e "\n"
echo -e "\e[00;32m[+]CPU使用率:  \e[00m"
echo -e "\n"
awk '$0 ~/cpu[0-9]/' /proc/stat 2>/dev/null | while read line; do
	echo "$line" | awk '{total=$2+$3+$4+$5+$6+$7+$8;free=$5;\
        print$1" Free "free/total*100"%",\
        "Used " (total-free)/total*100"%"}'
done
echo -e "\n"
#内存占用
echo -e "\e[00;32m[+]内存占用\e[00m"
free -mh
echo -e "\n"
#端口监听
echo -e "\e[00;32m[+]端口监听\e[00m"
echo -e "\n"
netstat -tulpen
echo -e "\n"
#对外开放端口
echo -e "\e[00;32m[+]对外开放端口\e[00m"
echo -e "\n"
netstat -tulpen | awk '{print $1,$4}' 
echo -e "\n"
#网络连接
echo -e "\e[00;32m[+]网络连接\e[00m"
echo -e "\n"
netstat -antop
echo -e "\n"
#路由表
echo -e "\e[00;32m[+]路由表\e[00m"
echo -e "\n"
/sbin/route -nee
echo -e "\n"
#DNS
echo -e "\e[00;32m[+]DNS Server\e[00m"
echo -e "\n"
cat /etc/resolv.conf
echo -e "\n"
#安装软件
echo -e "\e[00;32m[+]常用软件\e[00m"
echo -e "\n"
cmdline=(
	"which perl"
	"which gcc"
	"which g++"
	"which python"
	"which php"
	"which cc"
	"which go"
	"which node"
	"which clang"
	"which ruby"
	"which curl"
	"which wget"
	"which mysql"
	"which redis"
	"which apache"
	"which nginx"
	"which git"
	"which mongodb"
	"which docker"
	"which tftp"
	"which psql"
)

for prog in "${cmdline[@]}"; do
	soft=$($prog)
	if [ "$soft" ] 2>/dev/null; then
		echo -e "$soft"
	fi
done
echo -e "\n"
#定时任务
echo -e "\e[00;32m[+]定时任务\e[00m"
echo -e "\n"
crontab -u root -l
ls -al /etc/cron.*/*
echo -e "\n"
#passwd信息
echo -e "\e[00;32m[+]passwd\e[00m"
echo -e "\n"
cat /etc/passwd
echo -e "passwd文件修改日期:" $(stat /etc/passwd) 
echo -e "\n"
#防火墙
echo -e "\e[00;32m[+]IPTABLES防火墙\e[00m"
echo -e "\n"
iptables -L
echo -e "\n"
#登陆信息
echo -e "\e[00;32m[+]登录信息\e[00m"
echo -e "\n"
w
echo -e "\n"
echo -e "\e[00;32m[+]lastlog \e[00m"
echo -e "\n"
lastlog
echo -e "\n"
#...隐藏文件
echo -e "\e[00;32m[+]隐藏文件 \e[00m"
echo -e "\n"
find / ! -path "/proc/*" ! -path "/sys/*" ! -path "/run/*" ! -path "/boot/*" -name ".*."
echo -e "\n"
#tmp目录
echo -e "\e[00;32m[+]/tmp \e[00m"
echo -e "\n"
ls /tmp /var/tmp /dev/shm -alh
echo -e "\n"
#近7天改动
echo -e "\e[00;32m[+]近七天文件改动 \e[00m"
echo -e "\n"
find /etc /bin /sbin /dev /root/ /home /tmp -mtime -7 -type f | xargs -i{} ls -alh {}
echo -e "\n"
#检查ssh key
echo -e "\e[00;32m[+]SSH key\e[00m"
echo -e "\n"
sshkey=${HOME}/.ssh/authorized_keys
if [ -e "${sshkey}" ]; then
	cat ${sshkey}
else
	echo -e "SSH key文件不存在\n"
fi
echo -e "\n"
#查看自启服务
echo -e "\e[00;32m[+]查看自启服务 \e[00m"
echo -e "\n"
chkconfig --list 
echo -e "\n"
#查看隐藏程序
echo -e "\e[00;32m[+]查看隐藏程序 \e[00m"
echo -e "\n"
ps -ef|awk '{print }'|sort -n|uniq >1
ls /porc |sort -n|uniq >2
diff 1 2 
echo -e "\n"
echo -e "\e[00;34mEND GitHub https://github.com/birdhan\e[00m"
echo -e "\n"
