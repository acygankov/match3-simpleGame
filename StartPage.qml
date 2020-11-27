import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id:root

    signal startGame(int dimension)

    property int highScore: 0
    property int currentDimension: 8
    signal dimensionChanged(int dimension)

    ColumnLayout {
        anchors.fill: parent

        Text {
            Layout.alignment: Qt.AlignCenter
            text: "Match-3 game"
            font.bold: true
            font.family: "Hevletica"
            font.pointSize: 36
            color: "white"
            style: Text.Outline
            styleColor: "black"
        }

        Item {
            Layout.preferredHeight: 150
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            text: "Dimension"
            font.bold: true
            font.family: "Hevletica"
            font.pointSize: 24
            color: "white"
            style: Text.Outline
            styleColor: "black"
        }

        SpinBox {
            id: dimensionSpinBox

            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: 50
            Layout.preferredWidth: 200

            from: 4
            to: 10
            value: 8

            onValueChanged: {
                currentDimension = value
                dimensionChanged(value)
            }

            font.bold: true
            font.family: "Hevletica"
            font.pointSize: 24
        }

        Button {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: 50
            Layout.preferredWidth: 200

            text: "Start"
            font.bold: true
            font.family: "Hevletica"
            font.pointSize: 24

            onClicked: {
                root.startGame(dimensionSpinBox.value)
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            text: "High Score: " + Number.fromLocaleString(highScore)
            font.bold: true
            font.family: "Hevletica"
            font.pointSize: 24
            color: "white"
            style: Text.Outline
            styleColor: "black"
        }
    }
    color:"#757575"
}
