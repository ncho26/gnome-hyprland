//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

ShellRoot {
    id: root

    readonly property var specialClients: Hyprland.toplevels.values.filter(client => client.workspace?.name?.startsWith("special:"))

    function appClass(client: var): string {
        return client?.lastIpcObject?.class || client?.lastIpcObject?.initialClass || "app";
    }

    function appIcon(client: var): string {
        const cls = appClass(client);
        const icon = DesktopEntries.heuristicLookup(cls)?.icon;

        if (icon && (icon.includes("/") || Quickshell.hasThemeIcon(icon)))
            return Quickshell.iconPath(icon);

        if (Quickshell.hasThemeIcon(cls))
            return Quickshell.iconPath(cls);

        return "";
    }

    function currentWorkspaceName(): string {
        const focused = Hyprland.focusedWorkspace?.name ?? "";
        if (focused.length > 0 && !focused.startsWith("special:"))
            return focused;

        const monitorWorkspace = Hyprland.focusedMonitor?.activeWorkspace?.name ?? "";
        if (monitorWorkspace.length > 0 && !monitorWorkspace.startsWith("special:"))
            return monitorWorkspace;

        return "1";
    }

    function clientAddress(client: var): string {
        const address = client?.address ?? "";
        return address.startsWith("0x") ? address : `0x${address}`;
    }

    function activateClient(client: var): void {
        const targetWorkspace = currentWorkspaceName();
        const address = clientAddress(client);
        Hyprland.dispatch(`movetoworkspace ${targetWorkspace},address:${address}`);
        Hyprland.dispatch(`focuswindow address:${address}`);
    }

    function refreshHyprland(): void {
        Hyprland.refreshToplevels();
        Hyprland.refreshWorkspaces();
        Hyprland.refreshMonitors();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: var): void {
            const name = event.name;
            if (name.endsWith("v2"))
                return;

            if (name.includes("window") || name.includes("workspace") || ["activewindow", "activespecial", "focusedmon"].includes(name))
                root.refreshHyprland();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property ShellScreen modelData

            readonly property bool hasClients: root.specialClients.length > 0
            readonly property int iconSize: 72
            readonly property int buttonSize: 112
            readonly property int panelPadding: 18
            readonly property int panelSpacing: 14
            readonly property int panelHeight: buttonSize + panelPadding * 2
            readonly property int bottomGap: 18
            readonly property int maxInteractiveWidth: 600
            readonly property int interactiveWidth: Math.min(width, maxInteractiveWidth)
            readonly property int triggerHeight: 112
            property bool expanded: false
            property real offsetScale: expanded && hasClients ? 0 : 1

            function hideSoon(): void {
                hideTimer.restart();
            }

            screen: modelData
            visible: hasClients
            color: "transparent"

            WlrLayershell.namespace: "specialapps"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors.left: true
            anchors.right: true
            anchors.bottom: true

            implicitHeight: panelHeight + bottomGap + 18
            exclusiveZone: 0
            mask: hasClients ? expanded ? expandedMask : triggerMask : emptyMask

            onHasClientsChanged: {
                if (!hasClients)
                    expanded = false;
            }

            Behavior on offsetScale {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Timer {
                id: hideTimer

                interval: 180
                onTriggered: win.expanded = hoverArea.containsMouse || panelHover.containsMouse
            }

            Region {
                id: emptyMask
            }

            Region {
                id: triggerMask

                x: (win.width - win.interactiveWidth) / 2
                y: win.height - win.triggerHeight
                width: win.interactiveWidth
                height: win.triggerHeight
            }

            Region {
                id: expandedMask

                Region {
                    x: triggerMask.x
                    y: triggerMask.y
                    width: triggerMask.width
                    height: triggerMask.height
                }

                Region {
                    x: panel.x
                    y: panel.y
                    width: panel.width
                    height: panel.height
                    intersection: Intersection.Combine
                }
            }

            MouseArea {
                id: hoverArea

                anchors.fill: parent
                z: 100
                hoverEnabled: true
                acceptedButtons: Qt.NoButton

                onEntered: {
                    hideTimer.stop();
                    win.expanded = true;
                }
                onExited: win.hideSoon()
            }

            Rectangle {
                id: panel

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: win.bottomGap - (height + 32) * win.offsetScale

                width: Math.min(win.interactiveWidth, Math.max(win.panelHeight, iconsRow.implicitWidth + win.panelPadding * 2))
                height: win.panelHeight
                radius: 34
                opacity: 1 - win.offsetScale

                color: "#1e1e2ef2"
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.75
                    shadowOpacity: 0.35
                    shadowVerticalOffset: 8
                    shadowColor: "#000000"
                }

                MouseArea {
                    id: panelHover

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton

                    onEntered: {
                        hideTimer.stop();
                        win.expanded = true;
                    }
                    onExited: win.hideSoon()
                }

                Flickable {
                    anchors.fill: parent
                    anchors.margins: win.panelPadding

                    contentWidth: iconsRow.implicitWidth
                    contentHeight: height
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    interactive: contentWidth > width

                    RowLayout {
                        id: iconsRow

                        height: parent.height
                        spacing: win.panelSpacing

                        Repeater {
                            model: ScriptModel {
                                values: root.specialClients
                            }

                            Rectangle {
                                id: iconButton

                                required property var modelData
                                readonly property string iconSource: root.appIcon(modelData)
                                property bool hovered: false

                                Layout.preferredWidth: win.buttonSize
                                Layout.preferredHeight: win.buttonSize
                                Layout.alignment: Qt.AlignVCenter

                                radius: 26
                                color: hovered || modelData.activated ? "#313244f2" : "transparent"
                                border.width: 0

                                IconImage {
                                    visible: iconButton.iconSource.length > 0
                                    anchors.centerIn: parent

                                    width: win.iconSize
                                    height: win.iconSize
                                    source: iconButton.iconSource
                                    asynchronous: true
                                }

                                Rectangle {
                                    visible: iconButton.iconSource.length === 0
                                    anchors.centerIn: parent

                                    width: 66
                                    height: 66
                                    radius: 18
                                    color: "#89b4fa55"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onEntered: iconButton.hovered = true
                                    onExited: iconButton.hovered = false
                                    onClicked: {
                                        root.activateClient(iconButton.modelData);
                                        win.expanded = false;
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
