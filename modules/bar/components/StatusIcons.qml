import qs.widgets
import qs.services
import qs.utils
import qs.config
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import QtQuick

Item {
    id: root

    property color colour: Colours.palette.m3secondary

    // Expose internal icon references for popout hover logic
    readonly property Item bluetooth: bluetooth
    readonly property Item wired_network: wired_network
    readonly property Item network: network
    readonly property real bs: bluetooth.y
    readonly property real be: repeater.count > 0 ? devices.y + devices.implicitHeight : bluetooth.y + bluetooth.implicitHeight

    clip: true

    implicitWidth: iconsLayout.implicitWidth
    implicitHeight: iconsLayout.implicitHeight

    Column {
        id: iconsLayout
        anchors.centerIn: parent
        spacing: Appearance.spacing.smaller // More spacing between icons
        topPadding: Appearance.spacing.larger
        bottomPadding: Appearance.spacing.larger

        MaterialIcon {
            id: bluetooth
            animate: true
            text: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
            color: root.colour
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            id: devices
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Appearance.spacing.smaller

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
            anchors.horizontalCenter: parent.horizontalCenter
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
