import Quickshell
import QtQuick
import Quickshell.Io

ShellRoot {
	id: root

	FileView {
		id:walFile

		path: "file:///home/cpm/.cache/wal/colors.json"
		watchChanges: true
		onFileChanged: this.reload()
	}

	property var pywal: {
		try {
			return JSON.parse(walFile.text());
		} catch (e) {
			return {
				special: { background: "#1e1e2e", foreground: "#cdd6f4" },
				colors: {
					color0: "#45475a", color1: "#f38ba8", color2: "#a6e3a1",
					color3: "#f9e2af", color4: "#89b4fa", color5: "#f5c2e7",
					color6: "#94e2d5", color7: "#bac2de"
				}
			};
		}
	}

	PanelWindow {

		anchors {
			top: true
		}

		color: root.pywal.special.background

		implicitHeight: 30
		implicitWidth: currentWindow.implicitWidth + 30
		aboveWindows: true

		Text {
			id: currentWindow
			anchors.centerIn: parent
			color: root.pywal.special.foreground

			Process {
				running: true
				command: [
					"sh",
					"-c",
					"swaymsg -m -t subscribe '[\"window\"]' | jq --unbuffered -r '.container | select(.focused) | .name'"
				]

				stdout: SplitParser {
					onRead: data => {
						var val = data.trim();
						if (val !== "") {
							currentWindow.text = val
						}
					}
				}
			}
		}
	}
}
