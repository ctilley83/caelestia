pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<AccessPoint> networks: []
    readonly property AccessPoint active: networks.find(n => n.active) ?? null
    readonly property list<EthernetConnection> wiredAdapters: []
    readonly property EthernetConnection activeEthernet: wiredAdapters.find(n => n.connected) ?? null

    reloadableId: "network"

    Process {
        running: true
        command: ["nmcli", "m"]
        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
    }

    Process {
        id: getNetworks
        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID", "d", "w"]
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                const networks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]),
                        frequency: parseInt(net[2]),
                        ssid: net[3],
                        bssid: net[4]?.replace(rep2, ":") ?? ""
                    };
                });
                const rNetworks = root.networks;

                const destroyed = rNetworks.filter(rn => !rNetworks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid));
                for (const network of destroyed)
                    rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                for (const network of networks) {
                    const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid);
                    if (match) {
                        match.lastIpcObject = network;
                    } else {
                        rNetworks.push(apComp.createObject(root, {
                            lastIpcObject: network
                        }));
                    }
                }
            }
        }
    }
    Process {
        id: getWiredStatus
        running: true
        command: ["nmcli", "-g", "DEVICE,STATE,IP4.ADDRESS", "device"]
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(l => l.startsWith("e"));
                const adapters = lines.map(line => {
                    const parts = line.split(":");
                    return {
                        device: parts[0],
                        state: parts[1],
                        ip: parts[2]?.split("/")[0] ?? ""
                    };
                });

                const rAdapters = root.wiredAdapters;

                const destroyed = rAdapters.filter(ra => !adapters.find(n => n.device === ra.device));
                for (const eth of destroyed)
                    rAdapters.splice(rAdapters.indexOf(eth), 1).forEach(n => n.destroy());

                for (const adapter of adapters) {
                    const match = rAdapters.find(n => n.device === adapter.device);
                    if (match) {
                        match.lastIpcObject = adapter;
                    } else {
                        rAdapters.push(ethComp.createObject(root, {
                            lastIpcObject: adapter
                        }));
                    }
                }
            }
        }
    }

    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
    }
    component EthernetConnection: QtObject {
        required property var lastIpcObject
        readonly property string device: lastIpcObject.device
        readonly property string state: lastIpcObject.state
        readonly property string ip: lastIpcObject.ip
        readonly property bool connected: lastIpcObject.state === "connected"
    }
    Component {
        id: ethComp
        EthernetConnection {}
    }

    Component {
        id: apComp

        AccessPoint {}
    }
}
