import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.12

import Match3 1.0

Window {
    id: root

    width: 800
    height: 600
    visible: true

    minimumWidth: 500
    minimumHeight: 300

    Settings {
        id: settings

        property bool isLetterEnabled
        property bool isSatIncEnabled
        property int currentDimension
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        interactive: false

        //Start page loader
        Loader {
            active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
            sourceComponent: StartPage {
                id: startPage

                onDimensionChanged: {
                    highScore = settings.value("highScore" + dimension.toLocaleString(), 0)
                }

                onStartGame: {
                    settings.currentDimension = dimension
                    settings.isLetterEnabled = letterEnabled
                    settings.isSatIncEnabled = saturationIncreased
                    gameAreaModel.dimension = dimension;
                    gameAreaModel.resetArea()

                    swipeView.currentIndex = 1
                }

                Component.onCompleted: {
                    startPage.currentDimension = settings.currentDimension
                    startPage.isLetterEnabled = settings.isLetterEnabled
                    startPage.isSatIncEnabled = settings.isSatIncEnabled
                    startPage.highScore = settings.value("highScore" + startPage.currentDimension.toLocaleString(), 0)
                }

            }
        }

        //Game page loader
        Loader {
            active: SwipeView.isCurrentItem

            sourceComponent: Item {
                //Background color gradient
                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(0, parent.height)
                    end: Qt.point(parent.width, 0)
                    layer.smooth: true
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#363636" }
                        GradientStop { position: 1.0; color: "#707070" }
                    }
                }

                RowLayout {
                    anchors.fill: parent

                    //Main game area
                    GameAreaGrid {
                        id: gameAreaGrid

                        Layout.alignment: Qt.AlignLeft
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        isLetterEnabled: settings.isLetterEnabled
                        isSatIncEnabled: settings.isSatIncEnabled

                        onIsGameOverChanged: {
                            if(gameAreaGrid.isGameOver) {
                                if(settings.value("highScore" + gameAreaModel.dimension.toLocaleString(), 0) < gameAreaModel.score)
                                    settings.setValue("highScore" + gameAreaModel.dimension.toLocaleString(), gameAreaModel.score)
                            }
                        }
                    }

                    //Game menu on the right
                    Rectangle {
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: Math.max(200, parent.width - gameAreaGrid.height)
                        Layout.fillHeight: true
                        color: "transparent"

                        ColumnLayout {
                            anchors.fill: parent

                            Text {
                                Layout.alignment: Qt.AlignCenter
                                text: qsTr("Score")


                                font.family: "Hevletica"
                                font.pointSize: 24
                                font.bold: true

                                color: "white"
                                style: Text.Outline
                                styleColor: "black"
                            }

                            Text {
                                Layout.alignment: Qt.AlignCenter
                                text: qsTr("%L1").arg(gameAreaModel.score)

                                font.family: "Hevletica"
                                font.pointSize: 24
                                font.bold: true

                                color: "white"
                                style: Text.Outline
                                styleColor: "black"
                            }

                            Text {
                                id: gameOverLabel

                                Layout.alignment: Qt.AlignCenter
                                text: qsTr("Game Over")

                                font.family: "Hevletica"
                                font.pointSize: 24
                                font.bold: true

                                color: "white"
                                style: Text.Outline
                                styleColor: "red"

                                visible: gameAreaGrid.isGameOver
                            }

                            //Center spacer
                            Item {
                                Layout.fillHeight: true
                            }

                            Button {
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 180

                                text: qsTr("Exit")

                                font.family: "Hevletica"
                                font.pointSize: 24
                                font.bold: true

                                onClicked: {
                                    swipeView.currentIndex = 0
                                }
                            }

                            //Bottom spacer
                            Item {
                                Layout.preferredHeight: 25
                            }
                        }
                    }
                }
            }
        }
    }
}
