pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import "../../services" as Services
import QtQuick.Window
import "../../config"

FloatingWindow {
    id: root
    readonly property string homeDir: Quickshell.env("HOME")
    title: "cheatsheet"
    implicitWidth: Screen.width * 0.75
    implicitHeight: Screen.height * 0.75
    visible: false
    color: "transparent"

    Shortcut {
        sequence: "Escape"
        onActivated: root.visible = false
    }

    Shortcut {
        sequence: "q"
        onActivated: root.visible = false
    }

    Process {
        id: toggleWatcher
        command: ["bash", "-c", "touch /tmp/cheatsheet_toggle && inotifywait -e close_write /tmp/cheatsheet_toggle"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.visible = !root.visible;
                toggleWatcher.running = false;
                toggleWatcher.running = true;
            }
        }
    }
    property var themeColours: ({})

    property var keybindsData: []

    Process {
        id: fetchTheme
        command: ["cat", root.homeDir + "/.local/state/caelestia/scheme.json"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var scheme = JSON.parse(this.text);
                    root.themeColours = scheme.colours;
                    console.log("Color scheme loaded successfully! Primary color: #" + root.themeColours.primary);
                    themeWatcher.running = true;
                } catch (e) {
                    console.log("Failed to parse color scheme JSON: " + e);
                }
            }
        }
    }

    Process {
        id: themeWatcher
        command: ["inotifywait", "-e", "close_write", root.homeDir + "/.local/state/caelestia/scheme.json"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("Wallpaper/color scheme change detected, preparing to reload");
                fetchTheme.running = false;
                fetchTheme.running = true;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.themeColours.surface ? ("#" + root.themeColours.surface) : '#1e1e2e'
        opacity: 0.5
        radius: 18

        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 30

            Text {
                text: "Caelestia Cheatsheet"
                font.family: Appearance.font.family.sans
                font.pixelSize: 32
                font.bold: true
                color: root.themeColours.primary ? ("#" + root.themeColours.primary) : "#cdd6f4"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 15
                columns: Math.max(1, Math.floor(parent.width / 395))

                Repeater {
                    model: Services.Keybinds.data

                    delegate: Item {
                        id: keyCard
                        required property var modelData
                        width: 380
                        height: 36

                        Row {
                            anchors.fill: parent
                            spacing: 16
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                id: keysRow
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                property var keyArray: keyCard.modelData.key.split(/\s*\+\s*|\s+/).filter(function (i) {
                                    return i;
                                })

                                Repeater {
                                    model: keysRow.keyArray

                                    delegate: Row {
                                        id: keyDelegate
                                        spacing: 6
                                        anchors.verticalCenter: parent.verticalCenter
                                        required property int index
                                        required property var modelData

                                        Rectangle {
                                            id: keycapBase
                                            width: keyText.implicitWidth + 16
                                            height: 28
                                            radius: 5
                                            color: root.themeColours.outline ? ("#" + root.themeColours.outline) : "#a6adc8"

                                            Rectangle {
                                                id: keycapTop
                                                anchors.fill: parent
                                                anchors.margins: 1
                                                anchors.bottomMargin: 4
                                                radius: 4
                                                color: root.themeColours.surface ? ("#" + root.themeColours.surface) : "#181825"
                                                border.width: 1
                                                border.color: root.themeColours.outlineVariant ? ("#" + root.themeColours.outlineVariant) : "#45475a"

                                                Text {
                                                    id: keyText
                                                    anchors.centerIn: parent
                                                    anchors.verticalCenterOffset: -1
                                                    text: keyDelegate.modelData.toUpperCase()
                                                    font.family: Appearance.font.family.mono
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                    color: root.themeColours.primary ? ("#" + root.themeColours.primary) : "#cdd6f4"
                                                }
                                            }
                                        }

                                        Text {
                                            text: "+"
                                            font.family: Appearance.font.family.mono
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: root.themeColours.onSurfaceVariant ? ("#" + root.themeColours.onSurfaceVariant) : "#a6adc8"
                                            anchors.verticalCenter: parent.verticalCenter
                                            visible: keyDelegate.index < (keysRow.keyArray.length - 1)
                                        }
                                    }
                                }
                            }

                            Text {
                                text: keyCard.modelData.desc
                                font.family: Appearance.font.family.sans
                                color: root.themeColours.onSurface ? ("#" + root.themeColours.onSurface) : "#f5e0dc"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                                width: keyCard.width - keysRow.width - parent.spacing
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
