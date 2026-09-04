import QtQuick 2.15
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

ShellRoot {
    id: shell

    property string theme: "gruvbox"
    property bool menuOpen: false
    property bool settingsOpen: false
    property bool powerOpen: false
    property bool notificationVisible: false
    property var latestNotification: null

    readonly property color background: theme === "gruvbox" ? "#d91d2021" : "#d918202b"
    readonly property color surface: theme === "gruvbox" ? "#ee282828" : "#ee243242"
    readonly property color hover: theme === "gruvbox" ? "#ee3c3836" : "#ee30485a"
    readonly property color accent: theme === "gruvbox" ? "#fabd2f" : "#9bdcff"
    readonly property color text: theme === "gruvbox" ? "#ebdbb2" : "#d9f0ff"
    readonly property color muted: theme === "gruvbox" ? "#a89984" : "#9bb9cc"
    readonly property color urgent: theme === "gruvbox" ? "#fb4934" : "#ff8fa3"

    function run(command) {
        Quickshell.execDetached(command)
    }

    function selectTheme(value) {
        theme = value
        run(["/home/nico/.config/waybar/scripts/theme-switcher.sh", value])
        menuOpen = false
    }

    function focusWorkspace(number) {
        run(["niri", "msg", "action", "focus-workspace", String(number)])
        menuOpen = false
    }

    NotificationServer {
        id: notificationServer
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        onNotification: function(notification) {
            shell.latestNotification = notification
            shell.notificationVisible = true
            notificationTimer.restart()
        }
    }

    Timer {
        id: notificationTimer
        interval: 6000
        onTriggered: shell.notificationVisible = false
    }

    PanelWindow {
        id: topBar
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 42
        exclusiveZone: 42
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            color: shell.background
            border.color: shell.accent
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 4

                Text {
                    width: 34
                    anchors.verticalCenter: parent.verticalCenter
                    text: "⛏"
                    color: shell.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: 1
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter
                    color: shell.accent
                }

                Repeater {
                    model: 9
                    delegate: Rectangle {
                        width: 27
                        height: 27
                        anchors.verticalCenter: parent.verticalCenter
                        color: mouse.containsMouse ? shell.hover : "transparent"
                        border.color: shell.muted
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: shell.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: shell.focusWorkspace(index + 1)
                        }
                    }
                }

                Item { width: 1; height: 1 }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "NICO // NIRI"
                    color: shell.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    MouseArea {
                        anchors.fill: parent
                        onClicked: shell.menuOpen = !shell.menuOpen
                    }
                }

                Item { width: 1; height: 1 }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(new Date(), "ddd dd MMM  •  HH:mm")
                    color: shell.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }

                Rectangle {
                    width: 34
                    height: 27
                    anchors.verticalCenter: parent.verticalCenter
                    color: powerMouse.containsMouse ? shell.hover : "transparent"
                    border.color: shell.urgent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "⏻"
                        color: shell.urgent
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: powerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: shell.powerOpen = !shell.powerOpen
                    }
                }

                Rectangle {
                    width: 34
                    height: 27
                    anchors.verticalCenter: parent.verticalCenter
                    color: settingsMouse.containsMouse ? shell.hover : "transparent"
                    border.color: shell.accent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "⚙"
                        color: shell.accent
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: settingsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: shell.settingsOpen = !shell.settingsOpen
                    }
                }
            }
        }
    }

    PanelWindow {
        id: notificationWindow
        visible: shell.notificationVisible && shell.latestNotification !== null
        anchors {
            top: true
            right: true
        }
        margins.top: 54
        margins.right: 12
        implicitWidth: 360
        implicitHeight: 112
        color: "transparent"
        aboveWindows: true

        Rectangle {
            anchors.fill: parent
            color: shell.surface
            border.color: shell.accent
            border.width: 1
            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6
                Text {
                    text: shell.latestNotification ? shell.latestNotification.appName : ""
                    color: shell.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }
                Text {
                    text: shell.latestNotification ? shell.latestNotification.summary : ""
                    color: shell.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: shell.latestNotification ? shell.latestNotification.body : ""
                    color: shell.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    width: parent.width
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: shell.notificationVisible = false
            }
        }
    }

    PanelWindow {
        id: menuWindow
        visible: shell.menuOpen || shell.settingsOpen || shell.powerOpen
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        color: "#66000000"
        aboveWindows: true
        focusable: true

        Rectangle {
            width: shell.settingsOpen ? 560 : 390
            height: shell.settingsOpen ? 430 : 280
            anchors.centerIn: parent
            color: shell.background
            border.color: shell.accent
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Row {
                    width: parent.width
                    Text {
                        text: shell.settingsOpen ? "SYSTEM SETTINGS" : shell.powerOpen ? "SESSION CONTROL" : "DESKTOP CONTROL"
                        color: shell.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                    }
                    Item { width: parent.width - 180; height: 1 }
                    Text {
                        text: "×"
                        color: shell.muted
                        font.pixelSize: 24
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                shell.menuOpen = false
                                shell.settingsOpen = false
                                shell.powerOpen = false
                            }
                        }
                    }
                }

                Text {
                    visible: shell.settingsOpen
                    text: "THEMES"
                    color: shell.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }

                Row {
                    visible: shell.settingsOpen
                    spacing: 8
                    Repeater {
                        model: ["gruvbox", "orange", "purple"]
                        delegate: Rectangle {
                            width: 155
                            height: 42
                            color: shell.theme === modelData ? shell.hover : shell.surface
                            border.color: shell.theme === modelData ? shell.accent : shell.muted
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: modelData.toUpperCase()
                                color: shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: shell.selectTheme(modelData)
                            }
                        }
                    }
                }

                Text {
                    visible: shell.settingsOpen
                    text: "WALLPAPER / DESKTOP"
                    color: shell.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }

                Row {
                    visible: shell.settingsOpen
                    spacing: 8
                    Rectangle {
                        width: 240
                        height: 42
                        color: shell.surface
                        border.color: shell.muted
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "CITY // PASTEL BLUE"
                            color: shell.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: shell.run(["/home/nico/.config/niri/wallpaper-by-theme.sh"])
                        }
                    }
                    Rectangle {
                        width: 240
                        height: 42
                        color: shell.surface
                        border.color: shell.muted
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "WORKSPACE OVERVIEW"
                            color: shell.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: shell.run(["niri", "msg", "action", "toggle-overview"])
                        }
                    }
                }

                Text {
                    visible: shell.menuOpen && !shell.settingsOpen && !shell.powerOpen
                    text: "THEME SWITCHER"
                    color: shell.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }

                Repeater {
                    visible: shell.menuOpen && !shell.settingsOpen && !shell.powerOpen
                    model: ["gruvbox", "orange", "purple"]
                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: shell.surface
                        border.color: shell.muted
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "APPLY " + modelData.toUpperCase()
                            color: shell.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: shell.selectTheme(modelData)
                        }
                    }
                }

                Column {
                    visible: shell.powerOpen
                    width: parent.width
                    spacing: 8
                    Repeater {
                        model: [
                            ["LOCK", ["loginctl", "lock-session"]],
                            ["SUSPEND", ["systemctl", "suspend"]],
                            ["REBOOT", ["systemctl", "reboot"]],
                            ["POWER OFF", ["systemctl", "poweroff"]]
                        ]
                        delegate: Rectangle {
                            width: parent.width
                            height: 40
                            color: shell.surface
                            border.color: shell.urgent
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: modelData[0]
                                color: shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: shell.run(modelData[1])
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: {
                shell.menuOpen = false
                shell.settingsOpen = false
                shell.powerOpen = false
            }
        }
    }
}
