import QtQuick
import Quickshell.Io
import qs.components
import qs.components.effects
import qs.services
import qs.config
import qs.utils

Item {
    id: root

    implicitWidth: Math.round(Appearance.font.size.large * 1.2)
    implicitHeight: Math.round(Appearance.font.size.large * 1.2)

    Process {
        id: toggleOverview
        command: ["qs", "-c", "caelestia", "ipc", "call", "pure_overview", "toggle"]
        running: false
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: toggleOverview.running = true
    }

    Loader {
        asynchronous: true
        anchors.centerIn: parent
        sourceComponent: SysInfo.isDefaultLogo ? caelestiaLogo : distroIcon
    }

    Component {
        id: caelestiaLogo

        Logo {
            implicitWidth: Math.round(Appearance.font.size.large * 1.6)
            implicitHeight: Math.round(Appearance.font.size.large * 1.6)
        }
    }

    Component {
        id: distroIcon

        ColouredIcon {
            source: SysInfo.osLogo
            implicitSize: Math.round(Appearance.font.size.large * 1.2)
            colour: Colours.palette.m3tertiary
        }
    }
}
