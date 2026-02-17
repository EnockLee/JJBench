#!/bin/bash

VERSION="0.1"

print_header() {
    clear
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
}

get_cpu_info() {
    echo
    echo "🧠 CPU 信息"
    echo "------------------------------------------"
    echo "CPU 型号     : $(grep 'model name' /proc/cpuinfo | head -1 | cut -d ':' -f2 | xargs)"
    echo "核心数量     : $(nproc)"
    echo "频率         : $(grep 'cpu MHz' /proc/cpuinfo | head -1 | awk '{print $4 " MHz"}')"
}

get_memory_info() {
    echo
    echo "💾 内存信息"
    echo "------------------------------------------"
    free -h
}

get_disk_info() {
    echo
    echo "🗄 磁盘信息"
    echo "------------------------------------------"
    df -hT | grep -E '^/dev/'
}

get_ip() {
    for api in \
        "https://api-ipv4.ip.sb/ip" \
        "https://ip.sb" \
        "https://myip.ipip.net" \
        "https://ifconfig.me"
    do
        ip=$(curl -4 -s --max-time 3 "$api" 2>/dev/null | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
        if [[ -n "$ip" ]]; then
            echo "$ip"
            return
        fi
    done
}

get_ipv6() {
    for api in \
        "https://api-ipv6.ip.sb/ip" \
        "https://ifconfig.me"
    do
        ip=$(curl -6 -s --max-time 3 "$api" 2>/dev/null)
        if [[ -n "$ip" ]]; then
            echo "$ip"
            return
        fi
    done
}

get_network_info() {
    echo
    echo "🌐 网络信息"
    echo "------------------------------------------"

    ipv4=$(get_ip)
    ipv6=$(get_ipv6)

    [ -n "$ipv4" ] && echo "IPv4 地址    : $ipv4" || echo "IPv4 地址    : 未检测到"
    [ -n "$ipv6" ] && echo "IPv6 地址    : $ipv6" || echo "IPv6 地址    : 未检测到"
}

test_io() {
    echo
    echo "🚀 I/O 磁盘测试"
    echo "------------------------------------------"

    io_result=$(dd if=/dev/zero of=testfile bs=64M count=16 conv=fdatasync 2>&1)
    io_speed=$(echo "$io_result" | grep -o '[0-9.]\+ MB/s')

    if [ -z "$io_speed" ]; then
        echo "磁盘写入速度 : 测试失败"
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
