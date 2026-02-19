#!/bin/bash

VERSION="0.3"

print_header() {
    [ -t 1 ] && clear
    echo "=========================================="
    echo "        JJBench - VPS 中文体检工具"
    echo "              Version $VERSION"
    echo "=========================================="
}

# 中文运行时间
get_uptime() {
    up_seconds=$(cut -d. -f1 /proc/uptime)

    days=$((up_seconds / 86400))
    hours=$(( (up_seconds % 86400) / 3600 ))
    minutes=$(( (up_seconds % 3600) / 60 ))

    uptime_str=""
    [ $days -gt 0 ] && uptime_str="${days}天 "
    [ $hours -gt 0 ] && uptime_str="${hours}小时 "
    uptime_str="${uptime_str}${minutes}分钟"

    echo "$uptime_str"
}

get_system_info() {
    echo
    echo "📦 系统信息"
    echo "------------------------------------------"
    echo "主机名       : $(hostname)"
    echo "操作系统     : $(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)"
    echo "内核版本     : $(uname -r)"
    echo "系统架构     : $(uname -m)"
    echo "运行时间     : $(get_uptime)"

    virt=$(systemd-detect-virt 2>/dev/null)
    if [ -n "$virt" ]; then
        echo "虚拟化类型   : $virt"
    else
        echo "虚拟化类型   : 未检测到"
    fi
}

get_cpu_info() {
    echo
    echo "🧠 CPU 信息"
    echo "------------------------------------------"
    echo "CPU 型号     : $(grep 'model name' /proc/cpuinfo | head -1 | cut -d ':' -f2 | xargs)"
    echo "核心数量     : $(nproc)"

    cpu_mhz=$(grep 'cpu MHz' /proc/cpuinfo | head -1 | awk '{print $4}')
    [ -n "$cpu_mhz" ] && echo "频率         : ${cpu_mhz} MHz"
}

get_memory_info() {
    echo
    echo "💾 内存信息"
    echo "------------------------------------------"
    free -h

    swap_total=$(free -h | awk '/Swap:/ {print $2}')
    if [[ "$swap_total" == "0B" ]]; then
        echo "Swap 状态     : 未开启"
    else
        echo "Swap 状态     : 已开启 ($swap_total)"
    fi
}

get_disk_info() {
    echo
    echo "🗄 磁盘信息"
    echo "------------------------------------------"
    df -hT | grep -E '^/dev/'

    fs_type=$(df -T / | awk 'NR==2 {print $2}')
    echo "根分区文件系统 : $fs_type"
}

get_ip() {
    curl -4 -s --max-time 3 https://api-ipv4.ip.sb/ip 2>/dev/null
}

get_ipv6() {
    curl -6 -s --max-time 3 https://api-ipv6.ip.sb/ip 2>/dev/null
}

get_network_info() {
    echo
    echo "🌐 网络信息"
    echo "------------------------------------------"

    ipv4=$(get_ip)
    ipv6=$(get_ipv6)
    local_ip=$(ip -4 addr show scope global | awk '/inet/ {print $2}' | cut -d/ -f1 | head -n1)

    [ -n "$local_ip" ] && echo "内网 IPv4    : $local_ip"

    if [ -n "$ipv4" ]; then
        echo "公网 IPv4    : $ipv4"
        if ip addr | grep -q "$ipv4"; then
            echo "公网绑定方式 : 直连公网"
        else
            echo "公网绑定方式 : NAT 出口"
        fi
    else
        echo "公网 IPv4    : 未检测到"
    fi

    [ -n "$ipv6" ] && echo "公网 IPv6    : $ipv6" || echo "公网 IPv6    : 未检测到"

    bbr=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')
    [ -n "$bbr" ] && echo "TCP 拥塞算法 : $bbr"

    echo
    echo "网络延迟测试 (ping 8.8.8.8)"
    ping -c 3 8.8.8.8 | grep avg | awk -F'/' '{print "平均延迟      : "$5" ms"}'
}

test_io() {
    echo
    echo "🚀 I/O 磁盘测试"
    echo "------------------------------------------"

    virt=$(systemd-detect-virt 2>/dev/null)

    if [[ "$virt" == "lxc" ]]; then
        echo "检测到 LXC 容器，使用兼容模式测试..."
        io_result=$(dd if=/dev/zero of=testfile bs=1M count=512 2>&1)
    else
        io_result=$(dd if=/dev/zero of=testfile bs=1M count=1024 oflag=direct 2>&1)
    fi

    io_speed=$(echo "$io_result" | grep -o '[0-9.]\+ MB/s')

    if [ -z "$io_speed" ]; then
        echo "磁盘写入速度 : 测试失败（可能被宿主限制）"
    else
        echo "磁盘写入速度 : $io_speed"
    fi

    rm -f testfile
}

print_footer() {
    echo
    echo "=========================================="
    echo "        体检完成"
    echo "=========================================="
}

main() {
    print_header
    get_system_info
    get_cpu_info
    get_memory_info
    get_disk_info
    get_network_info
    test_io
    print_footer
}

main
