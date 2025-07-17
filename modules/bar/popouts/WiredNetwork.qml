import qs.widgets
import qs.services
import qs.config
import QtQuick

Column {
    id: root

    spacing: Appearance.spacing.normal

    StyledText {
        text: qsTr("Device: %1").arg(Network.activeEthernet?.device ?? "None")
    }

    StyledText {
        text: qsTr("IP Address: %1").arg(Network.activeEthernet?.ip ?? "None")
    }

    StyledText {
        text: qsTr("State: %1").arg(Network.activeEthernet?.state ?? "disconnected")
    }

    StyledText {
        text: qsTr("Type: %1").arg(Network.activeEthernet?.type ?? "None")
    }
}
