import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id:root

    signal startGame(int dimension, bool letterEnabled, bool saturationIncreased)
    signal dimensionChanged(int dimension)

    property int highScore: 0
    property int currentDimension: 8

    property bool isLetterEnabled: false
    property bool isSatIncEnabled: false

    color:"#757575"

    ColumnLayout {
        anchors.fill: parent

        Text {
            Layout.alignment: Qt.AlignCenter
            text: qsTr("Match-3 game")

            font.family: "Hevletica"
            font.pointSize: 36
            font.bold: true

            color: "white"
            style: Text.Outline
            styleColor: "black"
        }

        Item {
            Layout.preferredHeight: 150
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            text: qsTr("Dimension")


            font.family: "Hevletica"
            font.pointSize: 24
            font.bold: true

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
            value: currentDimension

            font.family: "Hevletica"
            font.pointSize: 24
            font.bold: true

            onValueChanged: {
                dimensionChanged(value)
            }
        }

        Button {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: 50
            Layout.preferredWidth: 200

            text: qsTr("Start")

            font.family: "Hevletica"
            font.pointSize: 24
            font.bold: true

            onClicked: {
                root.startGame(dimensionSpinBox.value, letterEnableChkBox.checked, saturationIncChkBox.checked)
            }
        }

        CheckBox {
            id: letterEnableChkBox

            Layout.alignment: Qt.AlignCenter
            checked: isLetterEnabled

            indicator: Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                x: 0
                y: parent.height / 2 - height / 2
                radius: 3
                border.color: letterEnableChkBox.down ? "white" : "black"

                Rectangle {
                    width: 14
                    height: 14
                    x: 6
                    y: 6
                    radius: 2
                    color: letterEnableChkBox.down ? "white" : "black"
                    visible: letterEnableChkBox.checked
                }
            }

            contentItem: Text {
                leftPadding: letterEnableChkBox.indicator.width
                text: qsTr("Letter on ball")
                font.family: "Hevletica"
                font.pointSize: 14
                font.bold: true
                color: "white"
                style: Text.Outline
                styleColor: "black"
                verticalAlignment: Text.AlignVCenter
            }
        }

        CheckBox {
            id: saturationIncChkBox

            Layout.alignment: Qt.AlignCenter

            checked: isSatIncEnabled

            indicator: Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                x: 0
                y: parent.height / 2 - height / 2
                radius: 3
                border.color: saturationIncChkBox.down ? "white" : "black"

                Rectangle {
                    width: 14
                    height: 14
                    x: 6
                    y: 6
                    radius: 2
                    color: saturationIncChkBox.down ? "white" : "black"
                    visible: saturationIncChkBox.checked
                }
            }

            contentItem: Text {
                leftPadding: saturationIncChkBox.indicator.width
                text: qsTr("Increase saturation")
                font.family: "Hevletica"
                font.pointSize: 14
                font.bold: true
                color: "white"
                style: Text.Outline
                styleColor: "black"
                verticalAlignment: Text.AlignVCenter
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            text: qsTr("High Score: %L1").arg(highScore)

            font.family: "Hevletica"
            font.pointSize: 24
            font.bold: true

            color: "white"
            style: Text.Outline
            styleColor: "black"
        }
    }
}
