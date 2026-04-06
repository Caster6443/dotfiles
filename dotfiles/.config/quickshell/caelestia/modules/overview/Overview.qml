pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../services" as Services
import qs.config
import qs.components

PanelWindow {
    id: root
    anchors {
        left: true
        top: true
        bottom: true
    }
    margins {
        left: Config.bar.sizes.innerWidth + Math.max(Appearance.padding.smaller, Config.border.thickness) * 2
    }

    exclusionMode: ExclusionMode.Ignore

    implicitWidth: mainContainer.implicitWidth
    implicitHeight: mainContainer.implicitHeight
    visible: false
    color: "transparent"

    property string currentWallpaperPath: ""
    property var wsLayers: ({})

    Services.HyprlandData {
        id: localHyprData
    }

    ListModel {
        id: windowModel
    }

    function syncWindows(rawList) {
        if (!rawList)
            return;

        const nextMap = new Map();
        for (const w of rawList) {
            if (!w || !w.address)
                continue;
            const cls = (w.class || "").toLowerCase();
            const title = (w.title || "");
            const isO = cls.includes("quickshell") || title.includes("quickshell_pure_overview");
            if (isO)
                continue;
            const wsId = w.workspace?.id ?? 0;
            if (wsId < 1)
                continue;
            nextMap.set(w.address, w);
        }

        for (let i = windowModel.count - 1; i >= 0; --i) {
            if (!nextMap.has(windowModel.get(i).m_address))
                windowModel.remove(i);
        }

        const indexByAddr = {};
        for (let i = 0; i < windowModel.count; ++i)
            indexByAddr[windowModel.get(i).m_address] = i;

        for (const [addr, w] of nextMap) {
            const idx = indexByAddr[addr];
            const data = {
                m_address: addr,
                m_wsId: w.workspace?.id ?? 0,
                m_atX: w.at?.[0] ?? 0,
                m_atY: w.at?.[1] ?? 0,
                m_sizeW: w.size?.[0] ?? 0,
                m_sizeH: w.size?.[1] ?? 0,
                m_floating: !!w.floating,
                m_class: w.class ?? "",
                m_title: w.title ?? "",
                m_linearX: 20
            };
            if (idx === undefined) {
                windowModel.append(data);
            } else {
                for (const k in data) {
                    if (windowModel.get(idx)[k] !== data[k])
                        windowModel.setProperty(idx, k, data[k]);
                }
            }
        }
        root.recomputeAllLinearX();
    }

    function registerWorkspace(wsId, layerItem) {
        const nextLayers = Object.assign({}, root.wsLayers);
        nextLayers[wsId] = layerItem;
        root.wsLayers = nextLayers;
    }

    function recomputeLinearXForWs(wsId) {
        const arr = [];
        for (let i = 0; i < windowModel.count; ++i) {
            const it = windowModel.get(i);
            if (it.m_wsId !== wsId)
                continue;
            arr.push({
                idx: i,
                atX: it.m_atX,
                w: it.m_sizeW
            });
        }
        arr.sort((a, b) => a.atX - b.atX);

        const monW = Hyprland.focusedMonitor?.width || 1920;
        const gap = 40; 
        let totalW = 0;
        for (let j = 0; j < arr.length; ++j) {
            const w = arr[j].w > 0 ? arr[j].w : monW / 2;
            totalW += w;
        }
        if (arr.length > 0) {
            totalW += (arr.length - 1) * gap;
        }
        let xOffset = (Math.max(monW, totalW + gap * 2) - totalW) / 2;
        for (let j = 0; j < arr.length; ++j) {
            windowModel.setProperty(arr[j].idx, "m_linearX", xOffset);
            const w = arr[j].w > 0 ? arr[j].w : monW / 2;
            xOffset += w + gap;
        }
    }

    Process {
        id: hyprBatch
        running: false
    }

    function wsAddressesSortedByX(wsId) {
        const arr = [];
        for (let i = 0; i < windowModel.count; ++i) {
            const it = windowModel.get(i);
            if (it.m_wsId !== wsId)
                continue;
            arr.push({
                addr: it.m_address,
                atX: it.m_atX
            });
        }
        arr.sort((a, b) => a.atX - b.atX);
        return arr.map(e => e.addr);
    }

    function targetIndexForDrop(wsId, address, dropAtX) {
        const items = [];
        for (let i = 0; i < windowModel.count; ++i) {
            const it = windowModel.get(i);
            if (it.m_wsId !== wsId || it.m_address === address)
                continue;
            const w = it.m_sizeW > 0 ? it.m_sizeW : (Hyprland.focusedMonitor?.width || 1920) / 2;
            items.push({
                center: it.m_atX + w / 2
            });
        }
        items.sort((a, b) => a.center - b.center);
        let idx = 0;
        while (idx < items.length && dropAtX > items[idx].center)
            idx++;
        return idx;
    }

    function dispatchBatch(commands) {
        if (!commands || commands.length === 0)
            return;
        const batch = commands.join("; ");
        if (hyprBatch.running)
            hyprBatch.running = false;
        hyprBatch.command = ["hyprctl", "--batch", batch];
        hyprBatch.running = true;
    }

    function recomputeAllLinearX() {
        const seen = {};
        for (let i = 0; i < windowModel.count; ++i) {
            const wsId = windowModel.get(i).m_wsId;
            if (seen[wsId])
                continue;
            seen[wsId] = true;
            root.recomputeLinearXForWs(wsId);
        }
    }

    function anyWorkspaceLayer() {
        if (!root.wsLayers)
            return null;
        for (const k in root.wsLayers) {
            const layer = root.wsLayers[k];
            if (layer)
                return layer;
        }
        return null;
    }

    function restartSyncTimer() {
        syncTimer.restart();
    }

    Connections {
        target: localHyprData
        function onWindowListChanged() {
            root.syncWindows(localHyprData.windowList);
        }
    }

    Timer {
        id: syncTimer
        interval: 150
        onTriggered: localHyprData.updateAll()
    }

    Process {
        id: awwwQueryProc
        command: ["/usr/bin/awww", "query"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const match = this.text.match(/image:\s*([^\n\r]+)/);
                if (match && match[1])
                    root.currentWallpaperPath = "file://" + match[1].trim();
            }
        }
    }

    Timer {
        id: wallpaperTimer
        interval: 1000 
        repeat: true
        running: root.visible

        onTriggered: {
            awwwQueryProc.running = false;
            awwwQueryProc.running = true;
        }
    }

    IpcHandler {
        target: "pure_overview"
        function toggle() {
            root.visible = !root.visible;
        }
    }

    onVisibleChanged: {
        if (visible) {
            localHyprData.updateAll();
            root.syncWindows(localHyprData.windowList);
            awwwQueryProc.running = true;
        } else {
            awwwQueryProc.running = false;
        }
    }

    Rectangle {
        id: mainContainer
        color: "#CC11111b"
        radius: 24
        implicitWidth: grid.implicitWidth + 60
        implicitHeight: grid.implicitHeight + 60
        border.color: "#313244"
        border.width: 2
        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: 0
            bottomMargin: 0
        }

        Item {
            id: orphanLayer
            anchors.fill: parent
            visible: false
        }

        Grid {
            id: grid
            anchors.centerIn: parent
            columns: 1
            spacing: 25

            Repeater {
                model: 5
                delegate: WorkspaceCard {
                    overviewRoot: root
                    windowModel: windowModel
                }
            }
        }
    }

    Repeater {
        model: windowModel
        delegate: WindowPreview {
            overviewRoot: root
            orphanLayer: orphanLayer
        }
    }
}
