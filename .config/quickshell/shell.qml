import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    // Theme (gruvbox)
    property color colBg: "#282828"
    property color colFg: "#ebdbb2"
    property color colMuted: "#665c54"
    property color colCyan: "#d65d0e"
    property color colBlue: "#d5c4a1"
    property color colYellow: "#e0af68"
    property string fontFamily: "Iosevka Nerd Font"
    property int fontSize: 14
    
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: root.colBg

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // Workspaces
        Repeater {
            model: 9
            Text {
                property var ws: Hyprland.workspaces.values.find(w => w.id == index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id == (index + 1)
                text: index + 1
                color: isActive ? root.colCyan : (ws ? root.colBlue : root.colMuted)
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }

        Item { Layout.fillWidth: true }

        // CPU Widget with clickable dropdown
        CpuWidget {
            id: cpuWidget
            panelWindow: root
            textColor: root.colFg
            accentColor: root.colYellow
            popupBackground: root.colBg
            popupBorder: root.colMuted
            fontFamily: root.fontFamily
            fontSize: root.fontSize
            onOpened: { memoryWidget.close(); systemWidget.close() }
        }

        Rectangle { width: 1; height: 16; color: root.colMuted }

        // Memory Widget with clickable dropdown
        MemoryWidget {
            id: memoryWidget
            panelWindow: root
            textColor: root.colFg
            accentColor: root.colCyan
            popupBackground: root.colBg
            popupBorder: root.colMuted
            fontFamily: root.fontFamily
            fontSize: root.fontSize
            onOpened: { cpuWidget.close(); systemWidget.close() }
        }

        Rectangle { width: 1; height: 16; color: root.colMuted }

        // System Widget with dropdown menu
        // SystemWidget {
        //     id: systemWidget
        //     panelWindow: root
        //     textColor: root.colFg
        //     accentColor: root.colBlue
        //     popupBackground: root.colBg
        //     popupBorder: root.colMuted
        //     hoverColor: root.colMuted
        //     fontFamily: root.fontFamily
        //     fontSize: root.fontSize
        //     wallpaperPath: "~/Pictures/Wallpapers/"
        //     onOpened: { cpuWidget.close(); memoryWidget.close() }
        // }

        // Rectangle { width: 1; height: 16; color: root.colMuted }

        // Clock
        Text {
            id: clock
            color: root.colBlue
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            } 
        }
    }
}
