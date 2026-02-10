import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    // Theme properties - set these to match your bar
    property color textColor: "#ebdbb2"
    property color accentColor: "#d65d0e"
    property color popupBackground: "#282828"
    property color popupBorder: "#665c54"
    property color barColor: "#3d3d3d"
    property string fontFamily: "Iosevka Nerd Font"
    property int fontSize: 14

    // Reference to parent panel window for popup anchoring
    property var panelWindow: null

    // Signal emitted when popup opens
    signal opened()

    // Function to close the popup
    function close() {
        popup.visible = false
    }

    implicitWidth: memText.implicitWidth
    implicitHeight: parent ? parent.height : 30

    // Text display in bar
    Text {
        id: memText
        anchors.centerIn: parent
        text: "Memory: " + MemoryService.usedPercent + "%"
        color: root.accentColor
        font {
            family: root.fontFamily
            pixelSize: root.fontSize
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

    // Popup window for memory details
    PopupWindow {
        id: popup
        anchor.window: root.panelWindow ?? root.QsWindow.window
        anchor.rect.x: root.windowPos.x + (root.width / 2) - (popup.width / 2)
        anchor.rect.y: root.windowPos.y + root.height + 8
        anchor.edges: Edges.Top | Edges.Left

        width: 200
        height: contentColumn.implicitHeight + 16
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
                id: contentColumn
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                // RAM Usage row
                RowLayout {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "RAM"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                            bold: true
                        }
                        Layout.preferredWidth: 45
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 12
                        color: root.barColor

                        Rectangle {
                            width: parent.width * (MemoryService.usedPercent / 100)
                            height: parent.height
                            color: root.accentColor
                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    Text {
                        text: MemoryService.usedPercent + "%"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                        }
                        Layout.preferredWidth: 35
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // RAM details
                Text {
                    text: MemoryService.usedGb + " / " + MemoryService.totalGb + " GB"
                    color: root.textColor
                    font {
                        family: root.fontFamily
                        pixelSize: root.fontSize - 3
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.popupBorder
                }

                // Available
                RowLayout {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "Available"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                        }
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MemoryService.availableGb + " GB"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                        }
                    }
                }

                // Cached
                RowLayout {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "Cached"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                        }
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MemoryService.cachedGb + " GB"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                        }
                    }
                }

                // Buffers
                RowLayout {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "Buffers"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                        }
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MemoryService.buffersGb + " GB"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.popupBorder
                }

                // Swap Usage row
                RowLayout {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "Swap"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                            bold: true
                        }
                        Layout.preferredWidth: 45
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 12
                        color: root.barColor

                        Rectangle {
                            width: parent.width * (MemoryService.swapPercent / 100)
                            height: parent.height
                            color: root.accentColor
                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    Text {
                        text: MemoryService.swapPercent + "%"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                        }
                        Layout.preferredWidth: 35
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // Swap details
                Text {
                    text: MemoryService.swapUsedGb + " / " + MemoryService.swapTotalGb + " GB"
                    color: root.textColor
                    font {
                        family: root.fontFamily
                        pixelSize: root.fontSize - 3
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
