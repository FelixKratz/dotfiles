#!/usr/bin/env bash

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -eo pcpu,user)
CPU_SYS=$(echo "$CPU_INFO" | grep -v $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
CPU_USER=$(echo "$CPU_INFO" | grep $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")


CPU_PERCENT="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"

COLOR=0xffe1e3e4
case "$CPU_PERCENT" in
  [1-2][0-9]) COLOR=0xffeacb64
  ;;
  [3-6][0-9]) COLOR=0xfff69c5e
  ;;
  [7-9][0-9]|100) COLOR=0xffff6578
  ;;
esac


sketchybar --set cpu.percent label=$CPU_PERCENT% \
                             label.color=$COLOR \
           --push cpu.sys $CPU_SYS \
           --push cpu.user $CPU_USER
 


