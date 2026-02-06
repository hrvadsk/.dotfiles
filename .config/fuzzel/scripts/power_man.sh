#!/bin/sh

chosen=$(printf "Shutdown\nRestart\nLock" | fuzzel -d -l 3)

case "$chosen" in
        "Shutdown") shutdown now ;;
        "Restart") restart ;;
        "Lock") hyprlock ;;
        *) exit 1 ;;
esac
