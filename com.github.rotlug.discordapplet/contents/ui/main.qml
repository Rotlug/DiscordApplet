import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebSockets

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation
    property var users: []

    // Adjust sizing based on orientation
    Layout.minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Vertical
        ? 1
        : users.length * (root.height + 4)
    Layout.minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical
        ? users.length * (root.width + 4)
        : 1

    Layout.maximumWidth: Infinity
    Layout.maximumHeight: Infinity

    WebSocket {
        id: socket
        url: "ws://localhost:49152"
        active: true

        onTextMessageReceived: function(message) {
            try {
                users = JSON.parse(message)
            } catch (e) {
                console.error("Invalid JSON from WebSocket:", message)
            }
        }

        onStatusChanged: {
            console.log("WebSocket status changed:", socket.status)

            if (socket.status === WebSocket.Error || socket.status === WebSocket.Closed) {
                if (!reconnectTimer.running) reconnectTimer.start()
            } else if (socket.status === WebSocket.Open) {
                reconnectTimer.stop()
                socket.sendTextMessage("Hello!")
            }
        }
    }

    Timer {
        id: reconnectTimer
        interval: 3000
        repeat: true
        running: false

        onTriggered: {
            if (socket.status !== WebSocket.Open) {
                console.log("Attempting to reconnect WebSocket...")
                socket.active = false
                socket.active = true
            }
        }
    }

    GridLayout {
        id: avatarLayout
        anchors.fill: parent
        rowSpacing: 4
        columnSpacing: 4

        // Automatically switch layout structure
        rows: plasmoid.formFactor === PlasmaCore.Types.Vertical ? users.length : 1
        columns: plasmoid.formFactor === PlasmaCore.Types.Vertical ? 1 : users.length

        Repeater {
            model: users

            Image {
                Layout.preferredWidth: plasmoid.formFactor === PlasmaCore.Types.Vertical ? root.width : root.height
                Layout.preferredHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical ? root.width : root.height
                source: modelData.avatar
                fillMode: Image.PreserveAspectFit
                cache: false
                smooth: true
                clip: true
            }
        }
    }

    
    Connections {
        target: plasmoid
        function onFormFactorChanged() {
            console.log("Form factor changed:", plasmoid.formFactor)
            avatarLayout.rows = plasmoid.formFactor === PlasmaCore.Types.Vertical ? users.length : 1
            avatarLayout.columns = plasmoid.formFactor === PlasmaCore.Types.Vertical ? 1 : users.length
        }
    }
}

