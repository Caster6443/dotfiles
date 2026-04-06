pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects

Rectangle {
    id: windowItem

    required property string m_address
    required property int m_wsId
    required property real m_atX
    required property real m_atY
    required property real m_sizeW
    required property real m_sizeH
    required property real m_linearX
    required property bool m_floating

    required property var overviewRoot
    required property Item orphanLayer

    property string windowAddress: m_address
    property int currentWsId: m_wsId

    parent: (overviewRoot.wsLayers && overviewRoot.wsLayers[m_wsId]) ? overviewRoot.wsLayers[m_wsId] : (overviewRoot.anyWorkspaceLayer() ? overviewRoot.anyWorkspaceLayer() : orphanLayer)
    visible: parent !== orphanLayer
    z: 20
    scale: mouseArea.containsMouse ? 1.02 : 1.0
    opacity: mouseArea.drag.active ? 0.9 : 1.0

    Behavior on x {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }
    }
    Behavior on y {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }
    }
    Behavior on width {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    readonly property real scaleRatio: {
        const layer = parent;
        const container = layer ? layer.parent : null;
        return container && container.scaleRatio !== undefined ? container.scaleRatio : 1.0;
    }

    property real targetX: m_linearX * scaleRatio

    property real targetY: {
        const ph = parent ? parent.height : 260;
        const h = (m_sizeH > 0 ? m_sizeH : (Hyprland.focusedMonitor?.height || 1080)) * scaleRatio;
        return Math.max(0, (ph - h) / 2);
    }

    readonly property real clampedX: {
        const pw = parent ? parent.width : 0;
        if (!pw || isNaN(targetX) || isNaN(width))
            return targetX;
        return Math.max(0, Math.min(targetX, pw - width));
    }
    readonly property real clampedY: {
        const ph = parent ? parent.height : 0;
        if (!ph || isNaN(targetY) || isNaN(height))
            return targetY;
        return Math.max(0, Math.min(targetY, ph - height));
    }

    Binding on x {
        value: windowItem.clampedX
        when: !mouseArea.drag.active
    }
    Binding on y {
        value: windowItem.clampedY
        when: !mouseArea.drag.active
    }

    width: (m_sizeW > 0 ? m_sizeW : (Hyprland.focusedMonitor?.width || 1920) / 2) * scaleRatio
    height: (m_sizeH > 0 ? m_sizeH : (Hyprland.focusedMonitor?.height || 1080)) * scaleRatio

    radius: 6
    color: "#45475a"
    border.color: mouseArea.containsMouse ? "#cba6f7" : "#b4befe"
    border.width: 1

    ScreencopyView {
        id: screenView
        anchors.fill: parent
        anchors.margins: 1
        live: true

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: screenView.width
                height: screenView.height
                radius: 5
            }
        }

        captureSource: {
            for (let tl of ToplevelManager.toplevels.values) {
                if (`0x${tl.HyprlandToplevel?.address}` === windowAddress)
                    return tl;
            }
            return null;
        }
    }

    Drag.keys: ["window"]
    Drag.active: mouseArea.drag.active
    Drag.source: windowItem
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: windowItem
        hoverEnabled: true

        onPressed: {
            windowItem.z = 100;
            const layer = windowItem.parent;
            const container = layer ? layer.parent : null;
            if (container)
                container.hasActiveDrag = true;
        }

        onReleased: {
            windowItem.z = 1;
            const layer = windowItem.parent;
            const container = layer ? layer.parent : null;
            if (container)
                container.hasActiveDrag = false;

            windowItem.Drag.drop();

            const activeWs = Hyprland.focusedMonitor?.activeWorkspace?.id ?? -999;
            const monX = Hyprland.focusedMonitor?.x || 0;
            const monY = Hyprland.focusedMonitor?.y || 0;
            const realX = Math.round(windowItem.x / scaleRatio + monX);
            const realY = Math.round(windowItem.y / scaleRatio + monY);

            if (currentWsId === activeWs) {
                if (m_floating) {
                    Hyprland.dispatch(`movewindowpixel exact ${realX} ${realY},address:${windowAddress}`);
                } else {
                    const beforeOrder = overviewRoot.wsAddressesSortedByX(currentWsId);
                    const curIndex = beforeOrder.indexOf(windowAddress);
                    const targetIndex = overviewRoot.targetIndexForDrop(currentWsId, windowAddress, realX);
                    const delta = (curIndex !== -1) ? (targetIndex - curIndex) : 0;
                    if (delta !== 0) {
                        const dir = delta > 0 ? "r" : "l";
                        const cmds = [`dispatch focuswindow address:${windowAddress}`];
                        for (let step = 0; step < Math.abs(delta); ++step)
                            cmds.push(`dispatch layoutmsg swapcol ${dir}`);
                        overviewRoot.dispatchBatch(cmds);
                    }
                }
                overviewRoot.restartSyncTimer();
            }
        }

        onClicked: {
            Hyprland.dispatch(`focuswindow address:${windowAddress}`);
            overviewRoot.visible = false;
        }
    }
}
