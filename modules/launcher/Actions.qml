pragma Singleton

import "root:/utils/scripts/fuzzysort.js" as Fuzzy
import qs.services
import qs.config
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string qalcResult

    readonly property list<Action> list: [
        Action {
            name: qsTr("Calculator")
            desc: qsTr("Do simple math equations (powered by Qalc)")
            icon: "calculate"

            function onClicked(list: AppList): void {
                root.autocomplete(list, "calc");
            }
        },

        Action {
            name: qsTr("Theme")
            desc: qsTr("Change the current theme")
            icon: "colors"

            function onClicked(list: AppList): void {
                root.autocomplete(list, "theme ");
            }
        },
        Action {
            name: qsTr("Shutdown")
            desc: qsTr("Shutdown the system")
            icon: "power_settings_new"
            disabled: false

            function onClicked(list: AppList): void {
                list.visibilities.launcher = false;
                Quickshell.execDetached(["systemctl", "poweroff"]);
            }
        },
        Action {
            name: qsTr("Reboot")
            desc: qsTr("Reboot the system")
            icon: "cached"
            disabled: false

            function onClicked(list: AppList): void {
                list.visibilities.launcher = false;
                Quickshell.execDetached(["systemctl", "reboot"]);
            }
        },
        Action {
            name: qsTr("Logout")
            desc: qsTr("Log out of the current session")
            icon: "exit_to_app"
            disabled: !Config.launcher.enableDangerousActions

            function onClicked(list: AppList): void {
                list.visibilities.launcher = false;
                Quickshell.execDetached(["loginctl", "terminate-user", "ctilley"]);
            }
        },
        Action {
            name: qsTr("Lock")
            desc: qsTr("Lock the current session")
            icon: "lock"

            function onClicked(list: AppList): void {
                list.visibilities.launcher = false;
                Quickshell.execDetached(["loginctl", "lock-session"]);
            }
        }
    ]

    readonly property list<var> preppedActions: list.filter(a => !a.disabled).map(a => ({
        name: Fuzzy.prepare(a.name),
        desc: Fuzzy.prepare(a.desc),
        action: a
    }))

    function fuzzyQuery(search: string): var {
        return Fuzzy.go(search.slice(Config.launcher.actionPrefix.length), preppedActions, {
        all: true,
        keys: ["name", "desc"],
        scoreFn: r => r[0].score > 0 ? r[0].score * 0.9 + r[1].score * 0.1 : 0
    }).map(r => r.obj.action);
}

function autocomplete(list: AppList, text: string): void {
    list.search.text = `${Config.launcher.actionPrefix}${text}` ;
}

component Action: QtObject {
    required property string name
    required property string desc
    required property string icon
    property bool disabled

    function onClicked(list: AppList): void {
    }
}
}