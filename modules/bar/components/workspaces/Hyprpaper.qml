import QtQuick

QtObject {
    id: hyprpaperManager

    property var wallpapers: ({
        1: "~/.config/hypr/HyprPaper/enterprise_in_nebula.jpg",
        2: "~/.config/hypr/HyprPaper/cartoon_star_trek.png",
        3: "~/.config/hypr/HyprPaper/USS_Mosher.png",
        4: "~/.config/hypr/HyprPaper/trek_yourself.jpg",
        5: "~/.config/hypr/HyprPaper/blue_star_trek.jpg"
    })

    function getWallpaper(wsId) {
        return wallpapers[wsId] || wallpapers[1];
    }
}