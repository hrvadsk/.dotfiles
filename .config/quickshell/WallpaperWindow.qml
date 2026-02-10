import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: root

    // Theme properties
    property color textColor: "#ebdbb2"
    property color accentColor: "#d65d0e"
    property color popupBackground: "#282828"
    property color popupBorder: "#665c54"
    property color hoverColor: "#3d3d3d"
    property string fontFamily: "Iosevka Nerd Font"
    property int fontSize: 14

    // Wallpaper settings
    property string wallpaperPath: "~/Pictures/Wallpapers/"
    property var wallpaperList: []

    width: 600
    height: 450
    color: popupBackground
    visible: false

    function show() {
        visible = true
        scanWallpapers.running = true
    }

    // Scan for wallpapers
    Process {
        id: scanWallpapers
        command: ["bash", "-c", "find \"${HOME}/Pictures/Wallpapers\" -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \\) 2>/dev/null"]
        running: false

        stdout: SplitParser {
            onRead: line => {
                if (line && line.trim()) {
                    let newList = [...root.wallpaperList]
                    newList.push(line.trim())
                    root.wallpaperList = newList
                }
            }
        }

        onRunningChanged: {
            if (running) {
                root.wallpaperList = []
            }
        }
    }

    // Set wallpaper process
    Process {
        id: setWallpaper
        property string wallpaperFile: ""
        command: ["bash", "-c", "hyprctl hyprpaper preload '" + wallpaperFile + "' && hyprctl hyprpaper wallpaper ','" + wallpaperFile + ", cover'"]
        running: false
        

        onExited: {
            // Unload other wallpapers to free memory
            unloadWallpapers.running = true
        }
    }

    Process {
        id: unloadWallpapers
        command: ["bash", "-c", "hyprctl hyprpaper unload all"]
        running: false
    }

    Rectangle {
        anchors.fill: parent
        color: root.popupBackground
        border.color: root.popupBorder
        border.width: 1

        Column {
            anchors.fill: parent
            spacing: 0

            // Header
            Rectangle {
                width: parent.width
                height: 40
                color: root.hoverColor

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    Text {
                        text: "Wallpaper Manager"
                        color: root.textColor
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.wallpaperList.length + " wallpapers"
                        color: root.popupBorder
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize - 2
                        }
                    }

                    // Refresh button
                    Rectangle {
                        width: 28
                        height: 28
                        color: refreshMouse.containsMouse ? root.popupBorder : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "🔄"
                            font.pixelSize: root.fontSize
                        }

                        MouseArea {
                            id: refreshMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: scanWallpapers.running = true
                        }
                    }

                    // Close button
                    Rectangle {
                        width: 28
                        height: 28
                        color: closeMouse.containsMouse ? "#fb4934" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: root.textColor
                            font {
                                family: root.fontFamily
                                pixelSize: root.fontSize
                                bold: true
                            }
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.visible = false
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: root.popupBorder
            }

            // Wallpaper grid
            Flickable {
                width: parent.width
                height: parent.height - 41
                contentWidth: width
                contentHeight: gridLayout.implicitHeight + 20
                clip: true

                GridLayout {
                    id: gridLayout
                    width: parent.width - 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    columns: 3
                    rowSpacing: 10
                    columnSpacing: 10

                    Repeater {
                        model: root.wallpaperList

                        Rectangle {
                            id: wallpaperItem
                            Layout.preferredWidth: (gridLayout.width - 20) / 3
                            Layout.preferredHeight: Layout.preferredWidth * 0.6
                            color: root.hoverColor
                            border.color: itemMouse.containsMouse ? root.accentColor : root.popupBorder
                            border.width: itemMouse.containsMouse ? 2 : 1

                            property string filePath: modelData

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: "file://" + filePath
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true

                                // Loading indicator
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 40
                                    height: 40
                                    color: root.popupBackground
                                    visible: parent.status === Image.Loading

                                    Text {
                                        anchors.centerIn: parent
                                        text: "..."
                                        color: root.textColor
                                        font.family: root.fontFamily
                                    }
                                }
                            }

                            // Filename overlay
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 2
                                height: 22
                                color: Qt.rgba(0, 0, 0, 0.7)

                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - 8
                                    text: filePath.split('/').pop()
                                    color: root.textColor
                                    font {
                                        family: root.fontFamily
                                        pixelSize: root.fontSize - 4
                                    }
                                    elide: Text.ElideMiddle
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    setWallpaper.wallpaperFile = filePath
                                    setWallpaper.running = true
                                    root.visible = false
                                }
                            }

                            // Hover scale effect
                            scale: itemMouse.containsMouse ? 1.02 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    anchors.centerIn: parent
                    text: root.wallpaperList.length === 0 ? "No wallpapers found\nin " + root.wallpaperPath : ""
                    color: root.popupBorder
                    font {
                        family: root.fontFamily
                        pixelSize: root.fontSize
                    }
                    horizontalAlignment: Text.AlignHCenter
                    visible: root.wallpaperList.length === 0 && !scanWallpapers.running
                }

                // Loading state
                Text {
                    anchors.centerIn: parent
                    text: "Scanning wallpapers..."
                    color: root.accentColor
                    font {
                        family: root.fontFamily
                        pixelSize: root.fontSize
                    }
                    visible: scanWallpapers.running
                }
            }
        }
    }
}
