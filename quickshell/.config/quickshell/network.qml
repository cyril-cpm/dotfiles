import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

Scope {
    PanelWindow {
        id: wifiWindow

        // Position et dimensions de la fenêtre de test sur l'écran
        anchors {
            top: true
            right: true
        }
        margins {
            top: 40
            right: 40
        }
        width: 320
        height: 400
        color: "#1e1e2e" // Style sombre (Type Catppuccin Mocha)

        // Contenu principal
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            // 1. En-tête / Statut global
            Text {
                Layout.fillWidth: true
                text: "📡 Gestionnaire Wi-Fi"
                color: "#cdd6f4"
                font.bold: true
                font.pointSize: 14
            }

            // État de la connexion globale (connecté, déconnecté, etc.)
            Text {
                Layout.fillWidth: true
                // Networking.network donne accès aux infos globales
                text: "Statut : " + (Networking.network.connectivity ?? "Inconnu")
                color: "#a6adc8"
                font.pointSize: 10
            }

            // 2. Recherche et affichage de la carte Wi-Fi et des réseaux
            // On parcourt les périphériques réseau disponibles via Networking.devices
            // et on filtre pour trouver un WifiDevice.
            // (Astuce QML : on peut utiliser une ListView sur les dispositifs)
            
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: Networking.devices

                delegate: Item {
                    width: parent.width
                    height: wifiColumn.height + 10

                    // On vérifie si le périphérique est un WifiDevice
                    // modelData représente un NetworkDevice
                    ColumnLayout {
                        id: wifiColumn
                        width: parent.width
                        spacing: 6

                        // Affichage du nom de la carte Wi-Fi si c'en est une
                        Text {
                            visible: modelData.type === DeviceType.Wifi
                            text: "Carte : " + (modelData.interfaceName ?? "Wi-Fi")
                            color: "#fab387"
                            font.bold: true
                        }

                        // Si c'est un WifiDevice, on peut lister ses réseaux (modelData.networks)
                        ListView {
                            visible: modelData.type === DeviceType.Wifi
                            Layout.fillWidth: true
                            // Hauteur arbitraire pour l'exemple
                            implicitHeight: 200 
                            model: modelData.networks ?? []
                            
                            delegate: Rectangle {
                                width: parent.width
                                height: 35
                                color: modelData.connected ? "#313244" : "#181825"
                                radius: 6

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    Text {
                                        Layout.fillWidth: true
                                        // modelData ici est un WifiNetwork (ssid, connected, etc.)
                                        text: (modelData.ssid || "Réseau masqué") + (modelData.connected ? " (Connecté)" : "")
                                        color: modelData.connected ? "#a6e3a1" : "#bac2de"
                                        elide: Text.ElideRight
                                    }

                                    // Bouton de connexion rapide au clic
                                    // (Attention : ne gère pas la saisie de mot de passe s'il est protégé)
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (modelData.connected) {
                                                modelData.disconnect();
                                            } else {
                                                modelData.connect();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
