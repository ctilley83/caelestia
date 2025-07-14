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
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: {
                getWiredStatus.running = true;
            }
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
console.log("text wireless: ",text)
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
        command: ["nmcli", "device", "show", "eno1"]
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("Raw getWiredStatus output:\n" + text);

                const lines = text.split("\n");
                const ipLine = lines.find(l => l.includes("IP4.ADDRESS[1]:"));
                const typeLine = lines.find(l => l.includes("GENERAL.TYPE:"));
                console.log("type line is: ", typeLine);
                const ip = ipLine?.split(":")[1]?.trim()?.split("/")[0] ?? "";
                const type = typeLine?.split(":")[1]?.trim() ?? "";
                console.log("type is:", type);
                const entry = {
                    device: "eno1",
                    type: type,
                    state: ip ? "connected" : "disconnected",
                    ip
                };

                const match = root.wiredAdapters.find(n => n.device === "eno1");
                if (match) {
                    match.lastIpcObject = entry;
                } else {
                    root.wiredAdapters.push(ethComp.createObject(root, {
                        lastIpcObject: entry
                    }));
                }

                console.log("Parsed wired adapter (eno1):", entry);
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
        readonly property string type: lastIpcObject.type   // 👈 Add this
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
