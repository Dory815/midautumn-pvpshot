#!/usr/bin/env bash
set -euo pipefail
base="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$base"
tmux_args=(-L pvpshot-campus -f /dev/null)
running() { tmux "${tmux_args[@]}" has-session -t campus 2>/dev/null; }
send() {
    tmux "${tmux_args[@]}" send-keys -t campus:0.0 -l -- "$1"
    tmux "${tmux_args[@]}" send-keys -t campus:0.0 Enter
}
case "${1:-status}" in
    check)
        ./start.sh --check
        bash -n ./manage.sh
        ;;
    start)
        exec 9>"$base/.start.lock"
        flock -n 9 || { echo '另一个启动操作正在执行。'; exit 1; }
        if running; then echo '服务端已在运行。'; exit 0; fi
        ./start.sh --check
        if ! grep -Eq '^eula=true[[:space:]]*$' eula.txt; then
            echo '尚未接受 EULA；阅读 https://aka.ms/MinecraftEULA 并同意后设置 eula=true。'
            exit 1
        fi
        tmux "${tmux_args[@]}" new-session -d -s campus -c "$base" \
            'exec env PVPSHOT_MAX_MEMORY=3G ./start.sh' 9>&-
        echo '已提交后台启动。用 ./manage.sh status 查看状态和日志。'
        ;;
    stop)
        if ! running; then echo '服务端未运行。'; exit 0; fi
        send stop
        for ((i=0; i<60; i++)); do
            if ! running; then echo '服务端已退出。'; exit 0; fi
            sleep 1
        done
        echo '已发送 stop，进程仍在保存或退出；请查看日志，未强制结束。'
        exit 1
        ;;
    status)
        if running; then echo '后台会话：运行中'; else echo '后台会话：未运行'; fi
        port="$(sed -n 's/^server-port=//p' server.properties | tr -d '\r')"
        [[ "$port" =~ ^[0-9]+$ ]] || { echo 'server.properties 中的端口无效。'; exit 1; }
        ss -ltn "( sport = :$port )"
        if [[ -f logs/latest.log ]]; then tail -n 12 logs/latest.log;
        elif [[ -f startup.log ]]; then tail -n 12 startup.log; fi
        ;;
    command)
        shift
        [[ $# -gt 0 ]] || { echo '用法：./manage.sh command "服务器命令（无开头斜杠）"'; exit 1; }
        running || { echo '服务端未运行。'; exit 1; }
        send "$*"
        ;;
    console)
        exec tmux "${tmux_args[@]}" attach-session -t campus
        ;;
    *) echo '用法：./manage.sh {check|start|stop|status|command|console}'; exit 1 ;;
esac
