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

    readonly property real totalLayoutSize: (users.length * (plasmoid.formFactor === PlasmaCore.Types.Vertical ? root.width : root.height)) + ((users.length - 1) * 4)

    Layout.minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Vertical ? 1 : (users.length > 0 ? totalLayoutSize : Kirigami.Units.gridUnit)
    Layout.minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical ? (users.length > 0 ? totalLayoutSize : Kirigami.Units.gridUnit) : 1

    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    WebSocket {
        id: socket
        url: "ws://localhost:49152"
        active: true

        onTextMessageReceived: function (message) {
            try {
                root.users = JSON.parse(message);
            } catch (e) {
                console.error("Invalid JSON from WebSocket:", message);
            }
        }

        onStatusChanged: {
            if (socket.status === WebSocket.Error || socket.status === WebSocket.Closed) {
                if (!reconnectTimer.running) reconnectTimer.start();
            } else if (socket.status === WebSocket.Open) {
                reconnectTimer.stop();
                socket.sendTextMessage("Hello!");
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
                socket.active = false;
                socket.active = true;
            }
        }
    }

    fullRepresentation: Item {
        anchors.fill: parent

        Loader {
            anchors.fill: parent
            sourceComponent: plasmoid.formFactor === PlasmaCore.Types.Vertical ? verticalLayout : horizontalLayout
        }

        Component {
            id: horizontalLayout
            RowLayout {
                spacing: 4
                
                Repeater {
                    model: root.users
                    
                    Image {
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        Layout.maximumWidth: parent.height
                        Layout.maximumHeight: parent.height
                        
                        source: modelData.avatar
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        smooth: true
                    }
                }
            }
        }

        Component {
            id: verticalLayout
            ColumnLayout {
                spacing: 4
                
                Repeater {
                    model: root.users
                    
                    Image {
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.width
                        Layout.maximumWidth: parent.width
                        Layout.maximumHeight: parent.width
                        
                        source: modelData.avatar
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        smooth: true
                    }
                }
            }
        }
    }
}
