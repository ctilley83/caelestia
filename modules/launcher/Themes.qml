import "root:/themes"
import "root:/services/Colours.qml" as Colours
import "root:/paths" as Paths
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property list<var> list: []

    Component.onCompleted: {
        loadThemes();
       // loadLastTheme();
    }

    function loadThemes() {
        //const themeFiles = ["Lcars.qml", "Gruvbox.qml", "Oldschool.qml"];  // You can automate this later
        const themeFiles = ["Lcars.qml"];  // You can automate this later
        list = [];

        for (const file of themeFiles) {
            const comp = Qt.createComponent(`root:/themes/${file}`);
            if (comp.status === Component.Ready) {
                const instance = comp.createObject(root);
                list.push({
                    name: instance.name,
                    description: instance.description,
                    icon: instance.icon,
                    component: comp
                });
                instance.destroy();
            } else {
                console.warn("Failed to load theme component:", file);
            }
        }
    }

    function applyTheme(themeObj) {
        if (themeObj.component.status === Component.Ready) {
            const instance = themeObj.component.createObject(root);
            for (const prop in instance) {
                if (Colours.palette.hasOwnProperty(prop))
                    Colours.palette[prop] = instance[prop];
            }
            instance.destroy();

            Io.writeText(`${Paths.state}/theme.json`, JSON.stringify({ theme: themeObj.name }));
        } else {
            console.warn("Theme component not ready:", themeObj.name);
        }
    }

    function loadLastTheme() {
        const path = `${Paths.state}/theme.json`;
        if (Io.exists(path)) {
            const saved = JSON.parse(Io.readText(path));
            const themeObj = list.find(t => t.name === saved.theme);
            if (themeObj)
                applyTheme(themeObj);
        }
    }
}
