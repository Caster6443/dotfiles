pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string homeDir: Quickshell.env("HOME")

    property var data: []
    property bool isLoaded: false

    property Process fetcher: Process {
        command: [root.homeDir + "/.config/quickshell/caelestia/utils/bin/getkeybind", root.homeDir + "/.config/caelestia/hypr-user.conf", root.homeDir + "/.config/caelestia/hypr-vars.conf"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.data = JSON.parse(this.text);
                    root.isLoaded = true;
                    console.log("Keybinds data loaded successfully!");
                } catch (e) {
                    console.log("Failed to parse keybinds JSON: " + e);
                }
            }
        }
    }

    function reload() {
        fetcher.running = false;
        fetcher.running = true;
    }
}
