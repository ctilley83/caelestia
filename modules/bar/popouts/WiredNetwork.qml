import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick

Column {
    id: root

    spacing: Appearance.spacing.normal

    StyledText {
        text: qsTr("IP: %1").arg(Network.activeEthernet?.ip ?? "None")
    }

    StyledText {
        text: qsTr("Adapter: %1").arg(Network.activeEthernet?.device ?? "None")
    }

    StyledText {
        text: qsTr("Type: %1").arg(Network.activeEthernet?.type ?? "None")
    }
}
