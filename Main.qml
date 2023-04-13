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
        anchors.left: parent.right
        anchors.leftMargin: -50
        width: 50
        height: 50
        flat: true
        icon.name: "window-close"
        icon.height: 50
        icon.width: 50
        icon.color: "white"
        onClicked: {
            window.close()
        }
    }

    // Canvas
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50
        width: parent.width-16
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
                }
                onReleased: { canvas.draw = false }
                onPositionChanged: (mouse) => {
                    canvas.pos = Qt.point(mouse.x, mouse.y)
                    canvas.requestPaint()
                }
            }

            onPaint: {
                if (canvas.draw && canvas.pos != canvas.lastPos) {
                    var ctx = getContext("2d")
                    ctx.lineWidth = 5
                    ctx.strokeStyle = "grey"
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
