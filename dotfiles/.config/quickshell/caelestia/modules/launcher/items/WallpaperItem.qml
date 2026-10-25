import QtQuick
import Quickshell
import Caelestia.Config
import Caelestia.Models
import qs.components
import qs.components.effects
import qs.components.images
import qs.services

Item {
    id: root

    required property FileSystemEntry modelData
    required property ScreenState screenState
    property bool selecting: false

    scale: 0.5
    opacity: 0
    z: root.selecting ? 100 : (PathView.z ?? 0) // qmllint disable missing-property
    transform: Rotation {
        origin.x: root.width / 2
        origin.y: root.height / 2
        axis.x: 0
        axis.y: 1
        axis.z: 0
        angle: root.PathView.cardAngle ?? 0
    }

    Component.onCompleted: {
        scale = Qt.binding(() => PathView.onPath ? (root.selecting ? 2.2 : (root.PathView.cardScale ?? 0.8)) : 0);
        opacity = Qt.binding(() => PathView.onPath ? (root.PathView.cardOpacity ?? 1) : 0);
    }

    implicitWidth: image.width + Tokens.padding.medium * 2
    implicitHeight: image.height + label.height + Tokens.spacing.extraSmall + Tokens.padding.large + Tokens.padding.medium

    StateLayer {
        radius: Tokens.rounding.large
        onClicked: {
            if (root.selecting)
                return;

            root.PathView.view.currentIndex = root.PathView.index;
            root.selecting = true;
            Wallpapers.setWallpaper(root.modelData.path);
            closeAfterSelection.start();
        }
    }

    Elevation {
        anchors.fill: image
        radius: image.radius
        opacity: root.PathView.isCurrentItem ? 1 : 0
        level: 4

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    StyledClippingRect {
        id: image

        anchors.horizontalCenter: parent.horizontalCenter
        y: Tokens.padding.large
        color: Colours.tPalette.m3surfaceContainer
        radius: Tokens.rounding.large

        implicitWidth: Tokens.sizes.launcher.wallpaperWidth
        implicitHeight: implicitWidth / 4 * 3

        MaterialIcon {
            anchors.centerIn: parent
            text: "image"
            color: Colours.tPalette.m3outline
            fontStyle: Tokens.font.icon.builders.extraLarge.scale(2).weight(Font.DemiBold).build()
        }

        CachingImage {
            anchors.fill: parent
            path: root.modelData.path
            smooth: !root.PathView.view.moving
            sourceSize: {
                const dpr = (QsWindow.window as QsWindow)?.devicePixelRatio ?? 1;
                return Qt.size(image.implicitWidth * dpr, image.implicitHeight * dpr);
            }
        }

        StyledRect {
            width: root.selecting ? 68 : 48
            height: width
            radius: Tokens.rounding.full
            anchors.centerIn: parent
            color: Colours.palette.m3primary
            opacity: root.selecting ? 1 : 0
            scale: root.selecting ? 1 : 0.45

            Behavior on opacity {
                Anim {
                    type: Anim.FastEffects
                }
            }

            Behavior on scale {
                Anim {
                    type: Anim.FastSpatial
                }
            }

            MaterialIcon {
                anchors.centerIn: parent
                text: "check"
                color: Colours.palette.m3onPrimary
                fontStyle: Tokens.font.icon.builders.extraLarge.scale(1.2).build()
            }
        }
    }

    StyledText {
        id: label

        anchors.top: image.bottom
        anchors.topMargin: Tokens.spacing.extraSmall
        anchors.horizontalCenter: parent.horizontalCenter

        width: image.width - Tokens.padding.medium * 2
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        renderType: Text.QtRendering
        text: root.modelData.relativePath
        font: Tokens.font.label.medium
    }

    Behavior on scale {
        Anim {
            type: Anim.FastSpatial
        }
    }

    Behavior on opacity {
        Anim {
            type: Anim.DefaultEffects
        }
    }

    Timer {
        id: closeAfterSelection

        interval: 850
        onTriggered: root.screenState.launcher = false
    }
}
