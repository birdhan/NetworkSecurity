#!/bin/bash

echo ""
echo " ========================================================= "
echo " \                 Linux信息搜集脚本 V1.2                 / "
echo " ========================================================= "
echo " # 支持Centos、Debian系统检测                    "
echo " # author：al0ne                    "
echo -e "\n"
if [ $UID -ne 0 ]; then
	echo "请使用root权限运行！！！"
	exit 1
fi
source /etc/os-release
if ag -V >/dev/null 2>&1; then
	echo -n
else
	case ${ID} in
	"debian" | "ubuntu" | "devuan")
		apt-get -y install silversearcher-ag >/dev/null 2>&1
		;;
	"centos" | "rhel fedora" | "rhel")
		yum -y install the_silver_searcher >/dev/null 2>&1
		;;
	*)
		exit 1
		;;
	esac

fi
#Centos安装net-tools
if ifconfig >/dev/null 2>&1; then
	echo -n
else
	case ${ID} in
	"centos" | "rhel fedora" | "rhel")
		yum -y install net-tools >/dev/null 2>&1
		;;
	*)
		exit 1
		;;
	esac

fi
#Centos安装lsof
if lsof >/dev/null 2>&1; then
	echo -n
else
	case ${ID} in
	"centos" | "rhel fedora" | "rhel")
		yum -y install lsof >/dev/null 2>&1
		;;
	*)
		exit 1
		;;
	esac

fi
echo -e "\e[00;31m[+]系统改动\e[00m"
if debsums --help >/dev/null 2>&1; then
	debsums -e | ag -v 'OK'
else
	case ${ID} in
	"debian" | "ubuntu" | "devuan")
		apt install -y debsums >/dev/null 2>&1
		debsums -e | ag -v 'OK'
		;;
	"centos" | "rhel fedora" | "rhel")
		rpm -Va
		;;
	*)
		exit 1
		;;
	esac
fi
echo -e "\n"
echo -e "\e[00;31m[+]系统信息\e[00m"
#当前用户
echo -e "USER:\t\t" $(whoami) 2>/dev/null
#版本信息
echo -e "OS Version:\t" ${PRETTY_NAME}
#主机名
echo -e "Hostname: \t" $(hostname -s)
#uptime
echo -e "uptime: \t" $(uptime | awk -F ',' '{print $1}')
#cpu信息
echo -e "CPU info:\t" $(cat /proc/cpuinfo | ag -o '(?<=model name\t: ).*' | head -n 1)
# ipaddress
ipaddress=$(ifconfig | ag -o '(?<=inet |inet addr:)\d+\.\d+\.\d+\.\d+' | ag -v '127.0.0.1') >/dev/null 2>&1
echo -e "IPADDR:\t\t${ipaddress}" | sed ":a;N;s/\n/ /g;ta"
echo -e "\n"

echo -e "\e[00;31m[+]CPU使用率:  \e[00m"
awk '$0 ~/cpu[0-9]/' /proc/stat 2>/dev/null | while read line; do
	echo "$line" | awk '{total=$2+$3+$4+$5+$6+$7+$8;free=$5;\
        print$1" Free "free/total*100"%",\
        "Used " (total-free)/total*100"%"}'
done
echo -e "\n"
#CPU占用TOP 10
cpu=$(ps aux | grep -v ^'USER' | sort -rn -k3 | head -10) 2>/dev/null
echo -e "\e[00;31m[+]CPU TOP10:  \e[00m\n${cpu}\n"
#内存占用TOP 10
cpu=$(ps aux | grep -v ^'USER' | sort -rn -k3 | head -10) 2>/dev/null
echo -e "\e[00;31m[+]内存占用 TOP10:  \e[00m\n${cpu}\n"
#内存占用
echo -e "\e[00;31m[+]内存占用\e[00m"
free -mh
echo -e "\n"
#剩余空间
echo -e "\e[00;31m[+]剩余空间\e[00m"
df -mh
echo -e "\n"
echo -e "\e[00;31m[+]硬盘挂载\e[00m"
cat /etc/fstab | ag -v "#" | awk '{print $1,$2,$3}'
echo -e "\n"
#ifconfig
echo -e "\e[00;31m[+]ifconfig\e[00m"
/sbin/ifconfig -a
echo -e "\n"
#网络流量
echo -e "\e[00;31m[+]网络流量 \e[00m"
echo "Interface    ByteRec   PackRec   ByteTran   PackTran"
awk ' NR>2' /proc/net/dev | while read line; do
	echo "$line" | awk -F ':' '{print "  "$1"  " $2}' | \
	awk '{print $1"   "$2 "    "$3"   "$10"  "$11}'
done
echo -e "\n"
#端口监听
echo -e "\e[00;31m[+]端口监听\e[00m"
netstat -tulpen | ag 'tcp|udp.*' --nocolor
echo -e "\n"
#对外开放端口
echo -e "\e[00;31m[+]对外开放端口\e[00m"
netstat -tulpen | awk '{print $1,$4}' | ag -o '.*0.0.0.0:(\d+)' --nocolor
echo -e "\n"
#网络连接
echo -e "\e[00;31m[+]网络连接\e[00m"
netstat -antop | ag ESTAB --nocolor
echo -e "\n"
#连接状态
echo -e "\e[00;31m[+]TCP连接状态\e[00m"
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
echo -e "\n"
#路由表
echo -e "\e[00;31m[+]路由表\e[00m"
/sbin/route -nee
echo -e "\n"
#DNS
echo -e "\e[00;31m[+]DNS Server\e[00m"
cat /etc/resolv.conf | ag -o '\d+\.\d+\.\d+\.\d+' --nocolor
echo -e "\n"
#混杂模式
echo -e "\e[00;31m[+]网卡混杂模式\e[00m"
if ip link | ag PROMISC >/dev/null 2>&1; then
	echo "网卡存在混杂模式！"
else
	echo "网卡不存在混杂模式"

fi
echo -e "\n"
#安装软件
echo -e "\e[00;31m[+]常用软件\e[00m"
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
		echo -e "$soft" | ag -o '\w+$' --nocolor
	fi
done
echo -e "\n"
#crontab
echo -e "\e[00;31m[+]Crontab\e[00m"
crontab -u root -l | ag -v '#' --nocolor
ls -al /etc/cron.*/*
echo -e "\n"
#env
echo -e "\e[00;31m[+]env\e[00m"
env
echo -e "\n"
#LD_PRELOAD
echo -e "\e[00;31m[+]LD_PRELOAD\e[00m"
echo ${LD_PRELOAD}
echo -e "\n"
#passwd信息
echo -e "\e[00;31m[+]可登陆用户\e[00m"
cat /etc/passwd | ag -v 'nologin$|false$'
echo -e "passwd文件修改日期:" $(stat /etc/passwd | ag -o '(?<=Modify: ).*' --nocolor)
echo -e "\n"
echo -e "\e[00;31m[+]sudoers(请注意NOPASSWD)\e[00m"
cat /etc/sudoers | ag -v '#' | sed -e '/^$/d' | ag ALL --nocolor
echo -e "\n"
#防火墙
echo -e "\e[00;31m[+]IPTABLES防火墙\e[00m"
iptables -L
echo -e "\n"
#登陆信息
echo -e "\e[00;31m[+]登录信息\e[00m"
w
echo -e "\n"
last
echo -e "\n"
lastlog
echo "登陆ip:" $(ag -a accepted /var/log/secure /var/log/auth.* 2>/dev/null | ag -o '\d+\.\d+\.\d+\.\d+' | sort | uniq)
echo -e "\n"
#运行服务
echo -e "\e[00;31m[+]Service \e[00m"
case ${ID} in
"debian" | "ubuntu" | "devuan")
	service --status-all | ag -Q '+' --nocolor
	;;
"centos" | "rhel fedora" | "rhel")
	service --status-all | ag -Q 'is running' --nocolor
	;;
*)
	exit 1
	;;
esac
echo -e "\n"
#查看history文件
echo -e "\e[00;31m[+]History\e[00m"
ls -la ~/.*_history
ls -la /root/.*_history
echo -e "\n"
cat ~/.*history | ag '(?<![0-9])(?:(?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))(?![0-9])|http://|https://|ssh|scp|tar' --nocolor
echo -e "\n"
#HOSTS
echo -e "\e[00;31m[+]/etc/hosts \e[00m"
cat /etc/hosts | ag -v "#"
echo -e "\n"
#/etc/profile
echo -e "\e[00;31m[+]/etc/profile \e[00m"
cat /etc/profile | ag -v '#'
echo -e "\n"
#/etc/rc.local
echo -e "\e[00;31m[+]/etc/rc.local \e[00m"
cat /etc/rc.local | ag -v '#'
echo -e "\n"
#~/.bash_profile
echo -e "\e[00;31m[+]~/.bash_profile \e[00m"
cat ~/.bash_profile | ag -v '#'
echo -e "\n"
#~/.bashrc
echo -e "\e[00;31m[+]~/.bashrc \e[00m"
cat ~/.bashrc | ag -v '#'
echo -e "\n"
#bash反弹shell
echo -e "\e[00;31m[+]bash反弹shell \e[00m"
ps -ef | ag 'bash -i' | ag -v 'ag' | awk '{print $2}' | xargs -i{} lsof -p {} | ag 'ESTAB' --nocolor
echo -e "\n"
#...隐藏文件
echo -e "\e[00;31m[+]...隐藏文件 \e[00m"
find / ! -path "/proc/*" ! -path "/sys/*" ! -path "/run/*" ! -path "/boot/*" -name ".*."
echo -e "\n"
#tmp目录
echo -e "\e[00;31m[+]/tmp \e[00m"
ls /tmp /var/tmp /dev/shm -alh
echo -e "\n"
#alias 别名
echo -e "\e[00;31m[+]alias \e[00m"
alias|ag -v 'git'
echo -e "\n"
#SUID
echo -e "\e[00;31m[+]SUID \e[00m"
find / ! -path "/proc/*" -perm -004000 -type f | ag -v 'snap|docker'
echo -e "\n"
#lsof -L1
echo -e "\e[00;31m[+]lsof -L1 \e[00m"
lsof +L1
echo -e "\n"
#近7天改动
echo -e "\e[00;31m[+]近七天文件改动 \e[00m"
find /etc /bin /sbin /dev /root/ /home /tmp -mtime -7 -type f | ag -v 'cache|vim|/share/|/lib/|.zsh|.gem' | xargs -i{} ls -alh {}
echo -e "\n"
#大文件100mb
echo -e "\e[00;31m[+]大文件>100mb \e[00m"
find / ! -path "/proc/*" ! -path "/sys/*" ! -path "/run/*" ! -path "/boot/*" -size +100M -print 2>/dev/null | xargs -i{} ls -alh {} | ag '\.gif|\.jpeg|\.jpg|\.png|\.zip|\.tar.gz|\.tgz|\.7z|\.log|\.xz|\.rar|\.bak|\.old|\.sql|\.1|\.txt|\.tar|\.db|/\w+$' --nocolor
echo -e "\n"
#敏感文件
echo -e "\e[00;31m[+]敏感文件 \e[00m"
find / ! -path "/lib/modules*" ! -path "/usr/src*" ! -path "/snap*" ! -path "/usr/include/*" -regextype posix-extended -regex '.*sqlmap|.*msfconsole|.*\bncat|.*\bnmap|.*nikto|.*ettercap|.*backdoor|.*tunnel\.(php|jsp|asp|py)|.*\bnc|.*socks.(php|jsp|asp|py)|.*proxy.(php|jsp|asp|py)|.*brook.*|.*frps|.*frpc'
echo -e "\n"
#lsmod 可疑模块
echo -e "\e[00;31m[+]lsmod 可疑模块\e[00m"
sudo lsmod |ag -v "ablk_helper|ac97_bus|acpi_power_meter|aesni_intel|ahci|ata_generic|ata_piix|auth_rpcgss|binfmt_misc|bluetooth|bnep|bnx2|bridge|cdrom|cirrus|coretemp|crc_t10dif|crc32_pclmul|crc32c_intel|crct10dif_common|crct10dif_generic|crct10dif_pclmul|cryptd|dca|dcdbas|dm_log|dm_mirror|dm_mod|dm_region_hash|drm|drm_kms_helper|drm_panel_orientation_quirks|e1000|ebtable_broute|ebtable_filter|ebtable_nat|ebtables|edac_core|ext4|fb_sys_fops|floppy|fuse|gf128mul|ghash_clmulni_intel|glue_helper|grace|i2c_algo_bit|i2c_core|i2c_piix4|i7core_edac|intel_powerclamp|ioatdma|ip_set|ip_tables|ip6_tables|ip6t_REJECT|ip6t_rpfilter|ip6table_filter|ip6table_mangle|ip6table_nat|ip6table_raw|ip6table_security|ipmi_devintf|ipmi_msghandler|ipmi_si|ipmi_ssif|ipt_MASQUERADE|ipt_REJECT|iptable_filter|iptable_mangle|iptable_nat|iptable_raw|iptable_security|iTCO_vendor_support|iTCO_wdt|jbd2|joydev|kvm|kvm_intel|libahci|libata|libcrc32c|llc|lockd|lpc_ich|lrw|mbcache|megaraid_sas|mfd_core|mgag200|Module|mptbase|mptscsih|mptspi|nf_conntrack|nf_conntrack_ipv4|nf_conntrack_ipv6|nf_defrag_ipv4|nf_defrag_ipv6|nf_nat|nf_nat_ipv4|nf_nat_ipv6|nf_nat_masquerade_ipv4|nfnetlink|nfnetlink_log|nfnetlink_queue|nfs_acl|nfsd|parport|parport_pc|pata_acpi|pcspkr|ppdev|rfkill|sch_fq_codel|scsi_transport_spi|sd_mod|serio_raw|sg|shpchp|snd|snd_ac97_codec|snd_ens1371|snd_page_alloc|snd_pcm|snd_rawmidi|snd_seq|snd_seq_device|snd_seq_midi|snd_seq_midi_event|snd_timer|soundcore|sr_mod|stp|sunrpc|syscopyarea|sysfillrect|sysimgblt|tcp_lp|ttm|tun|uvcvideo|videobuf2_core|videobuf2_memops|videobuf2_vmalloc|videodev|virtio|virtio_balloon|virtio_console|virtio_net|virtio_pci|virtio_ring|virtio_scsi|vmhgfs|vmw_balloon|vmw_vmci|vmw_vsock_vmci_transport|vmware_balloon|vmwgfx|vsock|xfs|xt_CHECKSUM|xt_conntrack|xt_state|raid*|tcpbbr|btrfs|.*diag|psmouse|ufs|linear|msdos|cpuid|veth|xt_tcpudp|xfrm_user|xfrm_algo|xt_addrtype|br_netfilter|input_leds|sch_fq|ib_iser|rdma_cm|iw_cm|ib_cm|ib_core|.*scsi.*|tcp_bbr|pcbc|autofs4|multipath|hfs.*|minix|ntfs|vfat|jfs|usbcore|usb_common|ehci_hcd|uhci_hcd|ecb|crc32c_generic|button|hid|usbhid|evdev|hid_generic|overlay|xt_nat|qnx4"
echo -e "\n"
#检查ssh key
echo -e "\e[00;31m[+]SSH key\e[00m"
sshkey=${HOME}/.ssh/authorized_keys
if [ -e "${sshkey}" ]; then
	cat ${sshkey}
else
	echo -e "SSH key文件不存在\n"
fi
echo -e "\n"
#PHP webshell查杀
echo -e "\e[00;31m[+]PHP webshell查杀\e[00m"
ag --php -l -s 'assert\(|phpspy|c99sh|milw0rm|eval?\(|\(gunerpress|\(base64_decoolcode|spider_bc|shell_exec\(|passthru\(|base64_decode\s?\(|gzuncompress\s?\(|\(\$\$\w+|call_user_func\(|preg_replace_callback\(|preg_replace\(|register_shutdown_function\(|register_tick_function\(|mb_ereg_replace_callback\(|filter_var\(|ob_start\(|usort\(|uksort\(|GzinFlate\s?\(|\$\w+\(\d+\)\.\$\w+\(\d+\)\.|\$\w+=str_replace\(|eval\/\*.*\*\/\(' /
echo -e "\n"
rkhuntercheck() {
	if rkhunter >/dev/null 2>&1; then
		rkhunter --checkall --sk | ag -v 'OK|Not found|None found'
	else
		wget 'https://astuteinternet.dl.sourceforge.net/project/rkhunter/rkhunter/1.4.6/rkhunter-1.4.6.tar.gz' -O /tmp/rkhunter.tar.gz >/dev/null 2>&1
		tar -zxvf /tmp/rkhunter.tar.gz -C /tmp >/dev/null 2>&1
		cd /tmp/rkhunter-1.4.6/
		./installer.sh --install >/dev/null 2>&1
		rkhunter --checkall --sk | ag -v 'OK|Not found|None found'

	fi
}
ping -c 1 114.114.114.114 >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo -e "\e[00;31m[+]RKhunter\e[00m"
	rkhuntercheck
else
	echo -e '\n'
fi

