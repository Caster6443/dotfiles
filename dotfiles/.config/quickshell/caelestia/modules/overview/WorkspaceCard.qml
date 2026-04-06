pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: workspaceContainer

    required property int index
    required property var overviewRoot
    required property ListModel windowModel

    property int wsId: index + 1
    property bool hasActiveDrag: false

    readonly property real workspaceW: 400
    readonly property real workspaceH: 260

    property real contentMaxWidth: {
        let monW = Hyprland.focusedMonitor?.width || 1920;
        let totalW = 0;
        let count = 0;
        for (let i = 0; i < windowModel.count; ++i) {
            const it = windowModel.get(i);
            if (it.m_wsId !== wsId)
                continue;
            const w = it.m_sizeW;
            totalW += (w > 0 ? w : monW / 2);
            count++;
        }
        const gap = 40;
        if (count > 0) {
            totalW += (count - 1) * gap;
        }
        totalW += gap * 2;
        return Math.max(monW, totalW);
    }

    readonly property real scaleRatio: workspaceW / contentMaxWidth

    width: workspaceW
    height: workspaceH
    z: hasActiveDrag ? 100 : 0

    Rectangle {
        anchors.fill: parent
        radius: 18
        clip: true

        color: Hyprland.focusedMonitor?.activeWorkspace?.id === wsId ? "#313244" : "#1e1e2e"
        border.width: Hyprland.focusedMonitor?.activeWorkspace?.id === wsId ? 2 : 1
        border.color: Hyprland.focusedMonitor?.activeWorkspace?.id === wsId ? "#89b4fa" : "#45475a"

        Image {
            anchors.fill: parent
            source: overviewRoot.currentWallpaperPath
            fillMode: Image.PreserveAspectCrop
            opacity: 0.6
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                Hyprland.dispatch(`workspace ${wsId}`);
                overviewRoot.visible = false;
            }
        }

        DropArea {
            anchors.fill: parent
            keys: ["window"]
            onDropped: drop => {
                if (drop.source && drop.source.windowAddress) {
                    if (drop.source.currentWsId !== wsId) {
                        Hyprland.dispatch(`movetoworkspacesilent ${wsId},address:${drop.source.windowAddress}`);
                    }
                    drop.accepted = true;
                    // 调用主 root 的计时器
                    overviewRoot.restartSyncTimer();
                }
            }
        }
    }

    Item {
        id: windowLayer
        anchors.fill: parent
        z: 5
        Component.onCompleted: overviewRoot.registerWorkspace(wsId, windowLayer)
    }
}
