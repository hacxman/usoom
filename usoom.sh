#!/bin/bash

# 150MB is threshold
FREE_THR=150000

while true ; do
    MEMAVAIL=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    echo 'available memory:' $MEMAVAIL @ $(date +%s)

    if [ $MEMAVAIL -le $FREE_THR ] ; then
        RSSS=$(ls /proc/ | (awk '/^[0-9]+$/ {print $0}' | xargs -I{} awk '{print "{} "$2}' /proc/{}/statm))
        PID=0
        MAX_RSS=0
        MAX_PID=0
        for a in $RSSS; do
            if [ $PID -eq 0 ]; then
                PID=$a
            else
                echo $PID $a
                if [ $a -gt $MAX_RSS ]; then
                    MAX_RSS=$a
                    MAX_PID=$PID
                fi
                PID=0
            fi
        done
        echo $MAX_PID $MAX_RSS $MEMAVAIL
        echo kill $MAX_PID
        kill $MAX_PID
    fi
    sleep 1s
done
