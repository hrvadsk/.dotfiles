import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Theme properties
    property color textColor: "#ebdbb2"
    property color accentColor: "#d65d0e"
    property color popupBackground: "#282828"
    property color popupBorder: "#665c54"
    property color hoverColor: "#3d3d3d"
    property string fontFamily: "Iosevka Nerd Font"
    property int fontSize: 14

    // Reference to parent panel window for popup anchoring
    property var panelWindow: null

    // Wallpaper settings
    property string wallpaperPath: "~/Pictures/Wallpapers"

    // Signal emitted when popup opens
    signal opened()

    // Function to close the popup
    function close() {
        popup.visible = false
    }

    implicitWidth: systemText.implicitWidth
    implicitHeight: parent ? parent.height : 30

    // Wallpaper window instance
    WallpaperWindow {
        id: wallpaperWindow
        wallpaperPath: root.wallpaperPath
        textColor: root.textColor
        accentColor: root.accentColor
        popupBackground: root.popupBackground
        popupBorder: root.popupBorder
        fontFamily: root.fontFamily
        fontSize: root.fontSize
    }

    // Text display in bar
    Text {
        id: systemText
        anchors.centerIn: parent
        text: "⚙"
        color: root.accentColor
        font {
            family: root.fontFamily
            pixelSize: root.fontSize + 2
            bold: true
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                popup.visible = !popup.visible
                if (popup.visible) root.opened()
            }
        }
    }

    // Get position relative to window
    property point windowPos: {
        let item = root
        let x = 0
        let y = 0
        while (item && item.parent) {
            x += item.x
            y += item.y
            item = item.parent
        }
        return Qt.point(x, y)
    }

    // Popup menu
    PopupWindow {
        id: popup
        anchor.window: root.panelWindow ?? root.QsWindow.window
        anchor.rect.x: root.windowPos.x + (root.width / 2) - (popup.width / 2)
        anchor.rect.y: root.windowPos.y + root.height + 8
        anchor.edges: Edges.Top | Edges.Left

        width: 180
        height: menuColumn.implicitHeight + 16
        color: "transparent"

        visible: false

        Rectangle {
            id: popupContent
            anchors.fill: parent
            color: root.popupBackground
            border.color: root.popupBorder
            border.width: 1

            // Slide and fade animation
            transform: Translate {
                y: popup.visible ? 0 : -10
                Behavior on y {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }

            opacity: popup.visible ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                id: menuColumn
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                // Menu items
                MenuItem {
                    text: "Wallpaper Manager"
                    onClicked: {
                        popup.visible = false
                        wallpaperWindow.show()
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.popupBorder
                }

                MenuItem {
                    text: "Reload Hyprland"
                    onClicked: {
                        popup.visible = false
                        reloadHyprland.running = true
                    }
                }

                MenuItem {
                    text: "Exit Hyprland"
                    onClicked: {
                        popup.visible = false
                        exitHyprland.running = true
                    }
                }
            }
        }
    }

    // Menu item component
    component MenuItem: Rectangle {
        id: menuItem
        property string text: ""
        signal clicked()

        width: parent.width
        height: 28
        color: itemMouse.containsMouse ? root.hoverColor : "transparent"

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            text: menuItem.text
            color: root.textColor
            font {
                family: root.fontFamily
                pixelSize: root.fontSize - 2
            }
        }

        MouseArea {
            id: itemMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: menuItem.clicked()
        }
    }

    // Process for reloading Hyprland
    Process {
        id: reloadHyprland
        command: ["hyprctl", "reload"]
        running: false
    }

    // Process for exiting Hyprland
    Process {
        id: exitHyprland
        command: ["hyprctl", "dispatch", "exit"]
        running: false
    }
}
