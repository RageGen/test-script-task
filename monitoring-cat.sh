#!/bin/bash

PROCESS_NAME="btop"
PID_FILE="/home/ragegen/test-script-task/test_pid.txt"
LOG_FILE="/var/log/monitoring.log"
API_URL="https://catfact.ninja/fact"
CURL_TIMEOUT=5

log_message() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

PROCESS_PID=$(pgrep -x "$PROCESS_NAME")

if [ -z "$PROCESS_PID" ]; then
    exit 0
fi

if [ -f "$PID_FILE" ]; then
    LAST_PID=$(cat "$PID_FILE")

    if [ "$PROCESS_PID" != "$LAST_PID" ]; then
        log_message "Процесс $PROCESS_NAME был перезапущен. Новый PID: $PROCESS_PID"
    fi
fi

echo "$PROCESS_PID" > "$PID_FILE"

RESPONSE=$(curl --max-time $CURL_TIMEOUT -s $API_URL)

if [ $? -eq 0 ]; then
    FACT=$(echo $RESPONSE | jq -r '.fact')

    log_message "Получен факт о кошках: $FACT"
else
    log_message "Ошибка при запросе к API или сервер недоступен."
fi
