pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.config

Item {
    id: root

    required property DrawerVisibilities visibilities

    visible: width > 0
    implicitWidth: 0
    clip: true

    onVisibleChanged: if (visible) forceActiveFocus()

    Keys.onPressed: event => {
        if (content.item)
            content.item.handleKey(event);
    }

    states: State {
        name: "visible"
        when: root.visibilities.overview

        PropertyChanges {
            root.implicitWidth: content.item ? content.item.implicitWidth : 0
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                property: "implicitWidth"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                property: "implicitWidth"
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Loader {
        id: content

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        active: root.visibilities.overview || root.visible

        sourceComponent: Overview {
            visibilities: root.visibilities
        }
    }
}
