pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int usedPercent: 0
    property int swapPercent: 0
    property string usedGb: "0.0"
    property string totalGb: "0.0"
    property string swapUsedGb: "0.0"
    property string swapTotalGb: "0.0"
    property string availableGb: "0.0"
    property string buffersGb: "0.0"
    property string cachedGb: "0.0"

    property var memData: ({})

    Process {
        id: memProcess
        command: ["cat", "/proc/meminfo"]
        running: true

        stdout: SplitParser {
            onRead: line => root.parseMemLine(line)
        }

        onExited: (code, status) => {
            root.calculateMemory()
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: memProcess.running = true
    }

    function parseMemLine(line) {
        if (!line) return
        const parts = line.trim().split(/:\s+/)
        if (parts.length < 2) return

        const key = parts[0]
        const valueStr = parts[1].split(/\s+/)[0]
        const value = parseInt(valueStr) || 0

        memData[key] = value
    }

    function calculateMemory() {
        const total = memData["MemTotal"] || 1
        const free = memData["MemFree"] || 0
        const available = memData["MemAvailable"] || free
        const buffers = memData["Buffers"] || 0
        const cached = memData["Cached"] || 0
        const swapTotal = memData["SwapTotal"] || 0
        const swapFree = memData["SwapFree"] || 0

        const used = total - available
        const swapUsed = swapTotal - swapFree

        usedPercent = Math.round((used / total) * 100)
        swapPercent = swapTotal > 0 ? Math.round((swapUsed / swapTotal) * 100) : 0

        // Convert KB to GB
        totalGb = (total / 1048576).toFixed(1)
        usedGb = (used / 1048576).toFixed(1)
        availableGb = (available / 1048576).toFixed(1)
        buffersGb = (buffers / 1048576).toFixed(1)
        cachedGb = (cached / 1048576).toFixed(1)
        swapTotalGb = (swapTotal / 1048576).toFixed(1)
        swapUsedGb = (swapUsed / 1048576).toFixed(1)
    }
}
