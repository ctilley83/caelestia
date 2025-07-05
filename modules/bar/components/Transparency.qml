import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell

MaterialIcon {
    text: "opacity"
    color: Colours.palette.m3error
    font.bold: true
    font.pointSize: Appearance.font.size.normal

    StateLayer {
        anchors.fill: undefined
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1

        implicitWidth: parent.implicitHeight + Appearance.padding.small * 2
        implicitHeight: implicitWidth

        radius: Appearance.rounding.full

        function onClicked(): void {
            Colours.transparency.enabled = !Colours.transparency.enabled        }
    }
}