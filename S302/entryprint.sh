#!/bin/sh
cd "$(dirname "$0")" || exit 1

DELAY=${START_DELAY:-15}

shutdown() {
    echo "正在停止..."
    kill -TERM $PID1 $PID2 2>/dev/null
    wait $PID1 $PID2 2>/dev/null
    echo "容器已关闭"
    exit 0
}
trap shutdown TERM INT

./steamcommunity_302.cli &
PID1=$!
echo "Started steamcommunity_302.cli (PID: $PID1)"

echo "等待 ${DELAY} 秒后启动 Bot..."
sleep $DELAY

/init/TwitchDropsBot.Console &
PID2=$!
echo "Started TwitchDropsBot.Console (PID: $PID2)"

while true; do
    if ! kill -0 $PID1 2>/dev/null; then
        echo "代理掉线,正在终止Bot..."
        kill -TERM $PID2 2>/dev/null
        wait $PID2 2>/dev/null
        echo "容器停止"
        exit 0
    fi
    if ! kill -0 $PID2 2>/dev/null; then
        echo 1 > ./S302.exit
        echo "Bot掉线,正在终止代理..."
        kill -TERM $PID1 2>/dev/null
        wait $PID1 2>/dev/null
        echo "容器停止"
        exit 0
    fi
    sleep 1
done