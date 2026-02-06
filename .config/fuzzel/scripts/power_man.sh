#!/bin/sh

chosen=$(printf "Shutdown\nRestart\nLock" | fuzzel -d)

case "$chosen" in
        "Shutdown") shutdown now ;;
        "Restart") restart ;;
        "Lock") hyprlock ;;
        *) exit 1 ;;
esac
