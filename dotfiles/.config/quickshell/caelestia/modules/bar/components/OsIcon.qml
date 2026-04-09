import QtQuick
import Quickshell.Io
import qs.components
import qs.components.effects
import qs.services
import qs.config
import qs.utils

Item {
    id: root

    property var visibilities: null

    implicitWidth: Math.round(Appearance.font.size.large * 1.2)
    implicitHeight: Math.round(Appearance.font.size.large * 1.2)

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.visibilities)
                root.visibilities.overview = !root.visibilities.overview;
        }
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
