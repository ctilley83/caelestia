pragma Singleton
import "root:/utils/scripts/fuzzysort.js" as Fuzzy
import qs.config
import qs.services
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<Theme> list: [
        Theme {
            theme: "Gruvbox.json"
            icon: "palette"
            name: "Gruvbox"
            description: "Classic Gruvbox colour scheme which has some lameness to it"
        },
        Theme {
            theme: "Lcars.json"
            icon: "palette"
            name: "LCARS"
            description: "Star Trek LCARS-inspired interface"
        },
        Theme {
            theme: "Klingon.json"
            icon: "palette"
            name: "Klingon"
            description: "Bloody yet somehow still honorable"
        },
        Theme {
            theme: "FerengiDelight.json"
            icon: "palette"
            name: "Ferengi Delight"
            description: "I went with gold because it's cheaper than latinum"
        },
        Theme {
            theme: "AmberIce.json"
            icon: "palette"
            name: "Amber Ice"
            description: "It's iced out.. Plus its got snow man!"
        },
        Theme {
            theme: "MidnightMetro.json"
            icon: "palette"
            name: "Midnight Metro"
            description: "Dark and neon, just like the metro at night"
        },
        Theme {
            theme: "SolarStrike.json"
            icon: "palette"
            name: "Solar Strike"
            description: "You know wages suck when even the sun is on strike"
        },
        Theme {
            theme: "ObsidianRose.json"
            icon: "palette"
            name: "Obsidian Rose"
            description: "Idk, its got bright rosey stuff in it"
        },
        Theme {
            theme: "DeepCurrent.json"
            icon: "palette"
            name: "Deep Current"
            description: "Deep enough to crush a carbon fiber submarine"
        },
        Theme {
            theme: "BrightLight.json"
            icon: "palette"
            name: "Bright Light"
            description: "It's bright, it's light, it's a delight"
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

        const resolvedPath = Qt.resolvedUrl(`root:/themes/${theme}`);
        Colours.applyThemeFromJson(resolvedPath);
        Colours.persistThemePath(resolvedPath);
    }
}
}
