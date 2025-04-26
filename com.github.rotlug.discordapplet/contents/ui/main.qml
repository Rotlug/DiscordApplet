import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs

import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kquickcontrolsaddons 2.0
import QtWebSockets

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    property var users: []

    Layout.minimumWidth: users.length * root.height
    Layout.minimumHeight: 1

    Layout.maximumWidth: Infinity
    Layout.maximumHeight: Infinity

    WebSocket {
        id: socket
        url: "ws://localhost:2025"
        active: true

        onTextMessageReceived: function(message) {
            try {
                users = JSON.parse(message);
            } catch (e) {
                console.error("Invalid JSON from WebSocket:", message);
            }
        }

        onStatusChanged: {
            console.log("WebSocket status changed:", socket.status)

            if (socket.status === WebSocket.Error || socket.status === WebSocket.Closed) {
                if (!reconnectTimer.running) {
                    reconnectTimer.start()
                }
            } else if (socket.status === WebSocket.Open) {
                reconnectTimer.stop()
                socket.sendTextMessage("Hello!")
            }
        }
    }

    Timer {
        id: reconnectTimer
        interval: 3000 // 3 seconds
        repeat: true
        running: false

        onTriggered: {
            if (socket.status !== WebSocket.Open) {
                console.log("Attempting to reconnect WebSocket...")
                socket.active = false; // force close before retrying
                socket.active = true;  // reopen connection
            }
        }
    }

    RowLayout {
        id: avatarRow
        anchors.fill: parent
        // anchors.margins: 8
        // spacing: avatarSpacing

        Repeater {
            model: users

            Image {
                Layout.preferredWidth: root.height
                Layout.preferredHeight: root.height
                source: modelData.avatar
                fillMode: Image.PreserveAspectFit
                cache: false
                smooth: true
                clip: true
            }
        }
    }
}
