pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Caelestia.Components
import Caelestia.Config
import Caelestia.I18n
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.components.widgets
import qs.services
import qs.utils

Item {
    id: root

    property real playerProgress: {
        const active = Players.active;
        return active?.length ? (active.position % active.length) / active.length : 0;
    }

    readonly property real arcCoverGap: Tokens.spacing.extraSmall

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    implicitWidth: Tokens.sizes.dashboard.mediaWidth

    Behavior on playerProgress {
        Anim {
            type: Anim.StandardLarge
        }
    }

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: GlobalConfig.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    ServiceRef {
        service: Audio.beatTracker
    }

    CircularProgress {
        id: prog

        anchors.centerIn: cover
        implicitSize: cover.width + root.arcCoverGap + thickness * 2

        fgColour: Colours.palette.m3primary
        strokeWidth: Tokens.sizes.dashboard.mediaProgressThickness
        startAngle: -90 - sweepAngle / 2
        sweepAngle: Tokens.sizes.dashboard.mediaProgressSweep
        value: root.playerProgress

        wavy: true
        waveFrequency: 8
        waveDuration: 2000
        wavePaused: !Players.active?.isPlaying
    }

    CoverArt {
        id: cover

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Tokens.padding.medium + root.arcCoverGap + prog.thickness
        implicitHeight: width
    }

    StyledText {
        id: title

        anchors.top: cover.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Tokens.spacing.medium

        animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackTitle ?? Tr.tr("No media")) || Tr.tr("Unknown title")
        color: Colours.palette.m3primary
        font: Tokens.font.title.small

        width: parent.implicitWidth - Tokens.padding.extraLargeIncreased
        elide: Text.ElideRight
    }

    StyledText {
        id: album

        anchors.top: title.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Tokens.spacing.small

        animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackAlbum ?? Tr.tr("No media")) || Tr.tr("Unknown album")
        color: Colours.palette.m3outline
        font: Tokens.font.body.small

        width: parent.implicitWidth - Tokens.padding.extraLargeIncreased
        elide: Text.ElideRight
    }

    StyledText {
        id: artist

        anchors.top: album.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Tokens.spacing.small

        animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackArtist ?? Tr.tr("No media")) || Tr.tr("Unknown artist")
        color: Colours.palette.m3secondary

        width: parent.implicitWidth - Tokens.padding.extraLargeIncreased
        elide: Text.ElideRight
    }

    ButtonRow {
        id: controls

        anchors.top: artist.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Tokens.spacing.medium
        anchors.margins: Tokens.padding.large

        spacing: Tokens.spacing.extraSmall

        IconButton {
            type: IconButton.Tonal
            icon: "skip_previous"
            isRound: true
            shapeMorph: true
            disabled: !Players.active?.canGoPrevious
            onClicked: Players.active?.previous()
        }

        IconButton {
            fillWidth: true
            icon: Players.active?.isPlaying ? "pause" : "play_arrow"
            isRound: true
            shapeMorph: true
            checked: Players.active?.isPlaying ?? false
            disabled: !Players.active?.canTogglePlaying
            onClicked: Players.active?.togglePlaying()
        }

        IconButton {
            type: IconButton.Tonal
            icon: "skip_next"
            isRound: true
            shapeMorph: true
            disabled: !Players.active?.canGoNext
            onClicked: Players.active?.next()
        }
    }

    Item {
        id: spectrum

        readonly property int barCount: 32
        readonly property real centerX: width / 2
        readonly property real centerY: height / 2
        readonly property real innerRadius: Math.min(width, height) * 0.23
        readonly property real barRange: Math.min(width, height) * 0.21
        readonly property real energy: {
            const values = Audio.cava.values;
            const count = Math.min(8, values.length);
            let total = 0;
            for (let i = 0; i < count; i++)
                total += values[i] ?? 0;
            return count > 0 ? Math.min(1, total / count) : 0;
        }

        anchors.top: controls.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Tokens.spacing.small
        anchors.bottomMargin: Tokens.padding.large
        anchors.margins: Tokens.padding.extraLargeIncreased
        clip: true

        ServiceRef {
            service: Audio.cava
        }

        Shape {
            anchors.fill: parent
            asynchronous: true
            preferredRendererType: Shape.CurveRenderer
            data: bars.instances
        }

        Variants {
            id: bars

            model: Array.from({ length: spectrum.barCount }, (_, i) => i)

            ShapePath {
                id: bar

                required property int modelData
                property real level: Math.max(0.035, Math.min(1, Audio.cava.values[modelData] ?? 0))

                readonly property real angle: modelData * 2 * Math.PI / spectrum.barCount
                readonly property real outerRadius: spectrum.innerRadius + spectrum.barRange * level
                readonly property real cos: Math.cos(angle)
                readonly property real sin: Math.sin(angle)

                asynchronous: true
                capStyle: ShapePath.RoundCap
                strokeWidth: 3.5
                strokeColor: level > 0.55 ? "#69b5ff" : "#315f9b"
                fillColor: "transparent"

                startX: spectrum.centerX + spectrum.innerRadius * cos
                startY: spectrum.centerY + spectrum.innerRadius * sin

                PathLine {
                    x: spectrum.centerX + bar.outerRadius * bar.cos
                    y: spectrum.centerY + bar.outerRadius * bar.sin
                }

                Behavior on level {
                    NumberAnimation {
                        duration: 110
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on strokeColor {
                    CAnim {}
                }
            }
        }

        Rectangle {
            id: halo

            anchors.centerIn: parent
            width: spectrum.innerRadius * 2.05
            height: width
            radius: width / 2
            color: "transparent"
            border.color: "#315f9b"
            border.width: 1.5
            opacity: 0.38 + spectrum.energy * 0.5
            scale: 1 + spectrum.energy * 0.12

            Behavior on opacity {
                Anim {
                    type: Anim.FastEffects
                }
            }

            Behavior on scale {
                Anim {
                    type: Anim.FastEffects
                }
            }
        }

        Item {
            id: core

            anchors.centerIn: parent
            width: spectrum.innerRadius * 1.45
            height: width
            scale: 1 + spectrum.energy * 0.16

            Behavior on scale {
                Anim {
                    type: Anim.FastEffects
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#244879"
                opacity: 0.35 + spectrum.energy * 0.3
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: width / 2
                gradient: Gradient {
                    GradientStop { position: 0; color: "#b6ddff" }
                    GradientStop { position: 0.45; color: "#69b5ff" }
                    GradientStop { position: 1; color: "#315f9b" }
                }
            }

            MaterialIcon {
                anchors.centerIn: parent
                text: Players.active?.isPlaying ? "graphic_eq" : "music_note"
                color: "#f0f8ff"
                fontStyle: Tokens.font.icon.large
                animate: true
            }
        }
    }
}
