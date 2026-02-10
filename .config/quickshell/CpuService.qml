pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real totalUsage: 0
    property var coreUsages: []
    property int coreCount: 0

    // Previous readings for delta calculation
    property var prevTotal: []
    property var prevIdle: []
    property bool initialized: false

    Process {
        id: cpuProcess
        command: ["cat", "/proc/stat"]
        running: true

        stdout: SplitParser {
            onRead: line => root.parseCpuLine(line)
        }

        onExited: (code, status) => {
            root.initialized = true
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: cpuProcess.running = true
    }

    function parseCpuLine(line) {
        if (!line.startsWith("cpu")) return

        const parts = line.trim().split(/\s+/)
        const cpuName = parts[0]

        // Parse CPU times: user, nice, system, idle, iowait, irq, softirq, steal
        const user = parseInt(parts[1]) || 0
        const nice = parseInt(parts[2]) || 0
        const system = parseInt(parts[3]) || 0
        const idle = parseInt(parts[4]) || 0
        const iowait = parseInt(parts[5]) || 0
        const irq = parseInt(parts[6]) || 0
        const softirq = parseInt(parts[7]) || 0
        const steal = parseInt(parts[8]) || 0

        const totalTime = user + nice + system + idle + iowait + irq + softirq + steal
        const idleTime = idle + iowait

        if (cpuName === "cpu") {
            // Total CPU
            if (initialized && prevTotal.length > 0) {
                const totalDelta = totalTime - prevTotal[0]
                const idleDelta = idleTime - prevIdle[0]
                if (totalDelta > 0) {
                    totalUsage = Math.round(((totalDelta - idleDelta) / totalDelta) * 100)
                }
            }
            prevTotal[0] = totalTime
            prevIdle[0] = idleTime
        } else {
            // Individual core (cpu0, cpu1, etc.)
            const coreNum = parseInt(cpuName.substring(3))
            const coreIndex = coreNum + 1

            if (initialized && prevTotal[coreIndex] !== undefined) {
                const totalDelta = totalTime - prevTotal[coreIndex]
                const idleDelta = idleTime - prevIdle[coreIndex]
                if (totalDelta > 0) {
                    const usage = Math.round(((totalDelta - idleDelta) / totalDelta) * 100)
                    let newUsages = [...coreUsages]
                    newUsages[coreNum] = usage
                    coreUsages = newUsages
                }
            } else {
                let newUsages = [...coreUsages]
                newUsages[coreNum] = 0
                coreUsages = newUsages
            }

            prevTotal[coreIndex] = totalTime
            prevIdle[coreIndex] = idleTime

            if (coreNum + 1 > coreCount) {
                coreCount = coreNum + 1
            }
        }
    }
}
