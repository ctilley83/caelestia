import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/utils"
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

WrapperItem {
    readonly property real nonAnimWidth: (notifs.count > 0 ? Config.notifs.sizes.width : status.implicitWidth) + margin
    readonly property real nonAnimHeight: {
        if (notifs.count > 0) {
            const count = Math.min(notifs.count, Config.lock.maxNotifs);
            let height = status.implicitHeight + Appearance.spacing.normal + Appearance.spacing.smaller * (count - 1);
            for (let i = 0; i < count; i++)
                height += notifs.itemAtIndex(i)?.nonAnimHeight ?? 0;
            return height + margin;
        }

        return status.implicitHeight + margin;
    }

    implicitWidth: nonAnimWidth
    implicitHeight: nonAnimHeight

    margin: Appearance.padding.large * 2
    rightMargin: 0
    topMargin: 0

    Behavior on implicitWidth {
        Anim {
            duration: Appearance.anim.durations.large
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        Anim {
            duration: Appearance.anim.durations.large
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    ColumnLayout {
        spacing: Appearance.spacing.normal

        RowLayout {
            id: status

            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter

                animate: true
                text: Network.active ? Icons.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
                font.pointSize: Appearance.font.size.large
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter

                animate: true
                text: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
                font.pointSize: Appearance.font.size.large
            }
        }

        ListView {
            id: notifs

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: ScriptModel {
                values: [...Notifs.list].reverse()
            }

            orientation: Qt.Vertical
            spacing: 0
            clip: true
            interactive: false

            delegate: Item {
                id: wrapper

                required property Notifs.Notif modelData
                required property int index
                readonly property alias nonAnimHeight: notif.nonAnimHeight
                property int idx

                onIndexChanged: {
                    if (index !== -1)
                        idx = index;
                }

                implicitWidth: notif.implicitWidth
                implicitHeight: notif.nonAnimHeight + (idx === 0 ? 0 : Appearance.spacing.smaller)

                ListView.onRemove: removeAnim.start()

                SequentialAnimation {
                    id: removeAnim

                    PropertyAction {
                        target: wrapper
                        property: "ListView.delayRemove"
                        value: true
                    }
                    PropertyAction {
                        target: wrapper
                        property: "enabled"
                        value: false
                    }
                    PropertyAction {
                        target: wrapper
                        property: "implicitHeight"
                        value: 0
                    }
                    PropertyAction {
                        target: wrapper
                        property: "z"
                        value: 1
                    }
                    Anim {
                        target: notif
                        property: "x"
                        to: (notif.x >= 0 ? Config.notifs.sizes.width : -Config.notifs.sizes.width) * 2
                        duration: Appearance.anim.durations.normal
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                    PropertyAction {
                        target: wrapper
                        property: "ListView.delayRemove"
                        value: false
                    }
                }

                ClippingRectangle {
                    anchors.top: parent.top
                    anchors.topMargin: wrapper.idx === 0 ? 0 : Appearance.spacing.smaller

                    color: "transparent"
                    radius: notif.radius
                    implicitWidth: notif.implicitWidth
                    implicitHeight: notif.nonAnimHeight

                    Notification {
                        id: notif

                        modelData: wrapper.modelData
                    }
                }
            }

            move: Transition {
                Anim {
                    property: "y"
                }
            }

            displaced: Transition {
                Anim {
                    property: "y"
                }
            }

            StyledRect {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: Appearance.padding.normal

                color: Colours.palette.m3tertiaryContainer
                radius: Appearance.rounding.small

                implicitWidth: count.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: count.implicitHeight + Appearance.padding.small * 2

                scale: Notifs.popups.length > Config.lock.maxNotifs ? 1 : 0

                StyledText {
                    id: count

                    anchors.centerIn: parent
                    text: qsTr("+%1").arg(Notifs.popups.length - Config.lock.maxNotifs)
                    color: Colours.palette.m3onTertiaryContainer
                }

                Behavior on scale {
                    Anim {
                        duration: Appearance.anim.durations.expressiveFastSpatial
                        easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
                    }
                }
            }
        }
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }
}
