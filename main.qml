import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1
import Match3 1.0
import QtGraphicalEffects 1.12

Window {
    visible: true
    width: 800
    height: 600

    Settings {
        id: settings
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        interactive: false

        Loader {
            active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
            sourceComponent: StartPage {
                id: startPage
                highScore: settings.value("highScore" + currentDimension.toLocaleString(), 0)
                onDimensionChanged: {
                    highScore = settings.value("highScore" + dimension.toLocaleString(), 0)
                }

                onStartGame: {
                    gameAreaModel.dimension = dimension;
                    gameAreaModel.resetArea()
                    swipeView.currentIndex = 1
                }

                Component.onCompleted: {
                    startPage.highScore = settings.value("highScore" + startPage.currentDimension.toLocaleString(), 0)
                }
            }
        }

        Loader {
            active: SwipeView.isCurrentItem
            sourceComponent: Item {

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
                    GameAreaGrid {
                        id: gameAreaGrid

                        Layout.alignment: Qt.AlignLeft
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        onIsGameOverChanged: {
                            if(gameAreaGrid.isGameOver) {
                                if(settings.value("highScore" + gameAreaModel.dimension.toLocaleString(), 0) < gameAreaModel.score)
                                    settings.setValue("highScore" + gameAreaModel.dimension.toLocaleString(), gameAreaModel.score)
                            }
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: Math.max(200, parent.width - gameAreaGrid.height)
                        Layout.fillHeight: true
                        color: "transparent"

                        ColumnLayout {
                            anchors.fill: parent

                            Text {
                                Layout.alignment: Qt.AlignCenter
                                text: "Score"
                                font.bold: true
                                font.family: "Hevletica"
                                font.pointSize: 24
                                color: "white"
                                style: Text.Outline
                                styleColor: "black"
                            }

                            Text {
                                Layout.alignment: Qt.AlignCenter
                                text: Number.fromLocaleString(gameAreaModel.score)
                                font.bold: true
                                font.family: "Hevletica"
                                font.pointSize: 24
                                color: "white"
                                style: Text.Outline
                                styleColor: "black"
                            }

                            Text {
                                id: gameOverLabel
                                Layout.alignment: Qt.AlignCenter
                                text: "Game Over"
                                font.bold: true
                                font.family: "Hevletica"
                                font.pointSize: 24
                                color: "white"
                                style: Text.Outline
                                styleColor: "red"
                                visible: gameAreaGrid.isGameOver
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            Button {
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 180

                                text: "Exit"
                                font.bold: true
                                font.family: "Hevletica"
                                font.pointSize: 24

                                onClicked: {
                                    swipeView.currentIndex = 0
                                }
                            }

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
