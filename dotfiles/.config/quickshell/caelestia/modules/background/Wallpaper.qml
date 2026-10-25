pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.filedialog
import qs.components.images
import qs.services
import qs.utils

Item {
    id: root

    property string source: Wallpapers.current
    property Item current
    property bool completed

    onSourceChanged: {
        if (!completed)
            return;

        const previous = current;
        if (!source) {
            current = null;
            previous?.destroy();
        } else {
            current = imgComp.createObject(this, {
                path: source,
                previous: previous
            });
        }
    }

    Component.onCompleted: {
        completed = true;
        if (source)
            current = imgComp.createObject(this, {
                path: source
            });
    }

    Connections {
        target: Wallpapers

        function onSelectionAnimationIdChanged(): void {
            if (!root.current)
                return;

            selectionPulse.stop();
            root.current.scale = 1;
            selectionPulse.start();
        }
    }

    SequentialAnimation {
        id: selectionPulse

        NumberAnimation {
            target: root.current
            property: "scale"
            from: 1
            to: 1.09
            duration: 220
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root.current
            property: "scale"
            from: 1.09
            to: 1
            duration: 480
            easing.type: Easing.OutCubic
        }
    }

    Loader {
        asynchronous: true
        anchors.fill: parent

        active: root.completed && !root.source

        sourceComponent: StyledRect {
            color: Colours.palette.m3surfaceContainer

            Row {
                anchors.centerIn: parent
                spacing: Tokens.spacing.largeIncreased

                MaterialIcon {
                    text: "sentiment_stressed"
                    color: Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.builders.extraLarge.scale(5).build()
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Tokens.spacing.small

                    StyledText {
                        text: Tr.tr("Wallpaper missing?")
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.body.builders.large.size(28 * 2).weight(Font.Bold).build()
                    }

                    StyledRect {
                        implicitWidth: selectWallText.implicitWidth + Tokens.padding.extraLargeIncreased
                        implicitHeight: selectWallText.implicitHeight + Tokens.padding.small

                        radius: Tokens.rounding.full
                        color: Colours.palette.m3primary

                        FileDialog {
                            id: dialog

                            title: Tr.tr("Select a wallpaper")
                            filterLabel: Tr.tr("Image files")
                            filters: Images.validImageExtensions
                            onAccepted: path => Wallpapers.setWallpaper(path)
                        }

                        StateLayer {
                            radius: parent.radius
                            color: Colours.palette.m3onPrimary
                            onClicked: dialog.open()
                        }

                        StyledText {
                            id: selectWallText

                            anchors.centerIn: parent

                            text: Tr.tr("Set it now!")
                            color: Colours.palette.m3onPrimary
                            font: Tokens.font.body.large
                        }
                    }
                }
            }
        }
    }

    Component {
        id: imgComp

        Item {
            id: transition

            required property string path
            property Item previous
            property real reveal: 0
            property bool revealing: false
            property bool started: false
            readonly property int status: foreground.status
            readonly property real maxDiameter: Math.sqrt(width * width + height * height) * 1.04

            anchors.fill: parent
            z: root.current === transition ? 1 : 0

            function beginEnter(): void {
                if (started || foreground.status !== Image.Ready)
                    return;

                started = true;
                if (!previous)
                    return;

                revealing = true;
                revealAnim.start();
            }

            Component.onCompleted: Qt.callLater(beginEnter)

            Item {
                id: scene

                anchors.fill: parent
                layer.enabled: transition.revealing
                layer.effect: MultiEffect {
                    maskEnabled: transition.revealing
                    maskSpreadAtMin: 0.01
                    maskSource: Item {
                        width: scene.width
                        height: scene.height
                        layer.enabled: true

                        Rectangle {
                            readonly property real diameter: transition.maxDiameter * transition.reveal

                            anchors.centerIn: parent
                            width: diameter
                            height: diameter
                            radius: diameter / 2
                            color: "white"
                        }
                    }
                }

                // A softened, cropped copy fills any space around the full-fit wallpaper.
                CachingImage {
                    anchors.fill: parent
                    path: transition.path
                    fillMode: Image.PreserveAspectCrop
                    scale: 1.08
                    opacity: 0.72

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.62
                        blurMax: 48
                        saturation: -0.28
                        brightness: -0.14
                    }
                }

                CachingImage {
                    id: foreground

                    anchors.fill: parent
                    path: transition.path
                    fillMode: Image.PreserveAspectFit
                }
            }

            Connections {
                target: foreground

                function onStatusChanged(): void {
                    transition.beginEnter();
                }
            }

            NumberAnimation {
                id: revealAnim

                target: transition
                property: "reveal"
                duration: 1000
                from: 0
                to: 1
                easing.type: Easing.OutCubic
                onFinished: {
                    transition.revealing = false;
                    transition.previous?.destroy();
                }
            }
        }
    }

}
