import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    id: window
    width: 800
    height: 200
    visible: true
    title: qsTr("Writeboard")
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "#444444"

    FontLoader {
        id: icons
        source: Qt.resolvedUrl("fonts/icons.woff2")
    }

    // Header
    MouseArea {
        height: 50
        width: parent.width
        property point pos: Qt.point(0, 0)

        onPressed: (mouse) => { pos = Qt.point(mouse.x, mouse.y) }
        onPositionChanged: (mouse) => {
            window.x += mouse.x - pos.x
            window.y += mouse.y - pos.y
        }
    }
    Button {
        id: fillButton
        anchors.left: parent.left
        anchors.leftMargin: 8
        height: 50
        width: fillText.width+10
        flat: true

        Text {
            id: fillText
            renderType: Text.NativeRendering
            font.pointSize: 12
            color: "white"
            text: ""
            anchors.centerIn: parent
        }
    }
    Button {
        id: closeButton
        anchors.left: parent.right
        anchors.leftMargin: -50
        width: 50
        height: 50
        flat: true
        onClicked: { window.close() }

        Text {
            renderType: Text.NativeRendering
            font.family: icons.font.family
            font.pointSize: 24
            color: "white"
            text: String.fromCodePoint(0xe5cd)
            anchors.centerIn: parent
        }
    }

    Button {
        id: spaceButton
        anchors.top: closeButton.bottom
        anchors.left: parent.right
        anchors.leftMargin: -50
        width: 50
        height: 50
        flat: true

        Text {
            renderType: Text.NativeRendering
            font.family: icons.font.family
            font.pointSize: 24
            color: "white"
            text: String.fromCodePoint(0xe256)
            anchors.centerIn: parent
        }
    }

    Button {
        id: backspaceButton
        anchors.top: spaceButton.bottom
        anchors.left: parent.right
        anchors.leftMargin: -50
        width: 50
        height: 50
        flat: true

        Text {
            renderType: Text.NativeRendering
            font.family: icons.font.family
            font.pointSize: 24
            color: "white"
            text: String.fromCodePoint(0xe14a)
            anchors.centerIn: parent
        }
    }

    Button {
        id: returnButton
        anchors.top: backspaceButton.bottom
        anchors.left: parent.right
        anchors.leftMargin: -50
        width: 50
        height: 50
        flat: true

        Text {
            renderType: Text.NativeRendering
            font.family: icons.font.family
            font.pointSize: 24
            color: "white"
            text: String.fromCodePoint(0xe31b)
            anchors.centerIn: parent
        }
    }

    // Canvas
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 50
        width: parent.width-58
        height: parent.height-58
        color: "#535353"

        Canvas {
            id: canvas
            anchors.fill: parent

            property point lastPos: Qt.point(0, 0)
            property point pos: Qt.point(0, 0)
            property bool draw: true

            MouseArea {
                anchors.fill: parent
                onPressed: (mouse) => {
                    canvas.draw = true
                    canvas.lastPos = Qt.point(mouse.x, mouse.y)
                    canvas.pos = Qt.point(mouse.x, mouse.y)
                    canvas.requestPaint()
                }
                onReleased: {
                    canvas.draw = false
                    canvas.save("/tmp/writeboard.png")
                }
                onPositionChanged: (mouse) => {
                    canvas.pos = Qt.point(mouse.x, mouse.y)
                    canvas.requestPaint()
                }
            }

            onPaint: {
                if (canvas.draw && canvas.pos != canvas.lastPos) {
                    var ctx = getContext("2d")
                    ctx.lineWidth = 5
                    ctx.strokeStyle = "#b3b3b3"
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.beginPath()
                    ctx.moveTo(canvas.lastPos.x, canvas.lastPos.y)
                    ctx.lineTo(canvas.pos.x, canvas.pos.y)
                    canvas.lastPos = canvas.pos
                    ctx.stroke()
                }
            }
        }

        // Guiding line
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 110
            width: parent.width-32
            height: 2
            color: "grey"
        }
    }
}
