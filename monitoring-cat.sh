#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
API_URL="https://catfact.ninja/fact"
PID_FILE="/home/ragegen/test/self_monitor.pid"
CURL_TIMEOUT=5

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

check_restart() {
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE")
        if [ "$old_pid" != "$$" ] && ps -p "$old_pid" >/dev/null 2>&1; then
            log "Обнаружен предыдущий процесс (PID: $old_pid)"
        elif [ "$old_pid" != "$$" ]; then
            log "Перезапуск. Новый PID: $$"
        fi
    fi
    echo $$ > "$PID_FILE"
}

main() {
    check_restart
    
    response=$(curl -sS --max-time "$CURL_TIMEOUT" "$API_URL" 2>&1)
    
    if [ $? -eq 0 ]; then
        fact=$(echo "$response" | jq -r '.fact' 2>/dev/null)
        [ -n "$fact" ] && log "Факт: $fact" || log "Ошибка парсинга"
    else
        log "Ошибка запроса: ${response:-Timeout}"
    fi
}

while true; do
    main
    sleep 60
done
