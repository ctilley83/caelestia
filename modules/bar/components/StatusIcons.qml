import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Item {
    id: root

    property color colour: Colours.palette.m3secondary

    readonly property Item network: network
    readonly property Item wired_network: wired_network
    readonly property real bs: bluetooth.y
    readonly property real be: repeater.count > 0 ? devices.y + devices.implicitHeight : bluetooth.y + bluetooth.implicitHeight

    clip: true
    implicitWidth: Math.max(network.implicitWidth, wired_network.implicitWidth, bluetooth.implicitWidth, devices.implicitWidth)
    implicitHeight: wired_network.implicitHeight + network.implicitHeight + bluetooth.implicitHeight + bluetooth.anchors.topMargin + (repeater.count > 0 ? devices.implicitHeight + devices.anchors.topMargin : 0)
    MaterialIcon {
        id: wired_network
        animate: true
        text: "lan"
        color: root.colour
        anchors.horizontalCenter: parent.horizontalCenter
    }
    MaterialIcon {
        id: network
        animate: true
        text: Network.active ? Icons.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
        color: root.colour
        anchors.top: wired_network.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MaterialIcon {
        id: bluetooth

        anchors.horizontalCenter: network.horizontalCenter
        anchors.top: network.bottom
        anchors.topMargin: Appearance.spacing.smaller / 2

        animate: true
        text: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
        color: root.colour
    }

    Column {
        id: devices

        anchors.horizontalCenter: bluetooth.horizontalCenter
        anchors.top: bluetooth.bottom
        anchors.topMargin: Appearance.spacing.smaller / 2

        spacing: Appearance.spacing.smaller / 2

        Repeater {
            id: repeater

            model: ScriptModel {
                values: Bluetooth.devices.filter(d => d.connected)
            }

            MaterialIcon {
                required property Bluetooth.Device modelData

                animate: true
                text: Icons.getBluetoothIcon(modelData.icon)
                color: root.colour
                fill: 1
            }
        }
    }



    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }
}
