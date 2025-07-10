import QtQuick
import Quickshell.Io

pragma Singleton

Item {
    id: root

    property var wallpapers: ({})

    FileView {
        id: configFile
        path: "/home/ctilley/.config/hypr/hyprpaper.conf"
        watchChanges: true

        onLoaded: parseConfig()
        onFileChanged: reload()
    }

    function parseConfig() {
        const lines = configFile.text().split(/\r?\n/);
        let index = 1;
        const newWallpapers = {};

        for (let line of lines) {
            line = line.trim();
            if (line.startsWith("preload")) {
                const match = line.match(/^preload\s*=\s*(.+)$/);
                if (match)
                    newWallpapers[index++] = match[1].trim();
            }
        }

        wallpapers = newWallpapers;
        console.log("Loaded wallpapers:", JSON.stringify(wallpapers));
    }

    function getWallpaper(wsId) {
        return wallpapers[wsId] || wallpapers[1];
    }
}
