pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var data: []
    property bool isLoaded: false

    property Process fetcher: Process {
        command: ["/home/caster/.config/quickshell/caelestia/utils/bin/getkeybind", "/home/caster/.config/hypr/hyprland/keybinds.conf", "/home/caster/.config/hypr/variables.conf"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.data = JSON.parse(this.text);
                    root.isLoaded = true;
                    console.log("快捷键数据加载成功！");
                } catch (e) {
                    console.log("解析快捷键 JSON 失败: " + e);
                }
            }
        }
    }

    function reload() {
        fetcher.running = false;
        fetcher.running = true;
    }
}
