pragma Singleton
import "root:/utils/scripts/fuzzysort.js" as Fuzzy
import "root:/config"
import "root:/services"
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property list<Theme> list: [
        Theme {
            theme: "Gruvbox.json"
            icon: "palette"
            name: "Gruvbox"
            description: "Classic Gruvbox colour scheme"
        },
        Theme {
            theme: "Lcars.json"
            icon: "palette"
            name: "LCARS"
            description: "Star Trek LCARS-inspired interface"
        }
    ]

    readonly property list<var> preppedThemes: list.map(t => ({
        name: Fuzzy.prepare(t.name),
        theme: t
    }))

    function fuzzyQuery(search: string): var {
        return Fuzzy.go(
        search.slice(`${Config.launcher.actionPrefix}theme `.length),
            preppedThemes,
            {
                all: true,
                key: "name"
            }
    ).map(r => r.obj.theme);
}

component Theme: QtObject {
    required property string theme
    required property string icon
    required property string name
    required property string description

    function onClicked(list) {
        console.log(`Theme selected: ${theme}`);
        list.visibilities.launcher = false;

        // Load theme via JSON path, resolving relative path
        const resolvedPath = Qt.resolvedUrl(`root:/themes/${theme}`);
        Colours.applyThemeFromJson(resolvedPath);
    }
}
}
