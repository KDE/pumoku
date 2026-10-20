// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.ki18n
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.pumoku.private

pragma ComponentBehavior: Bound

Kirigami.ScrollablePage {
    id: root
    required property bool gameLoaded
    required property GamePage gp
    property Kirigami.ApplicationWindow app: applicationWindow()

    title:KI18n.i18nc("@title:window", "Pumoku Menu")
    globalToolBarStyle: gameLoaded ? Kirigami.ApplicationHeaderStyle.Titles : Kirigami.ApplicationHeaderStyle.None
    verticalScrollBarInteractive: false
    padding: 0

    // saved games
    GamesModel {
        id: gamesModel
    }

    // prompt to save current game if any
    function promptSave(levelOrIndex, filename) {
        if (gp.hasGame) {
            if (filename) savePrompt.filename = filename
            savePrompt.levelOrIndex = levelOrIndex
            savePrompt.open()
        } else if (filename) {
            loadFile(levelOrIndex, filename)
        } else {
            newGame(levelOrIndex)
        }
    }

    function loadFile(index, filename) {
        if (gp.loadGame(filename)) {
            gamesModel.removeGame(filename, index)
        } else {
            console.log("Error!?: could not load saved game: " + filename)
        }
        app.pageStack.layers.pop()
    }

    function newGame(level) {
        gp.generateSudoku(level, 0)
        app.pageStack.layers.pop()
    }

     Kirigami.PromptDialog {
        id: savePrompt
        property int levelOrIndex: 0
        property string filename: ""
        title: KI18n.i18n("Save game?")
        subtitle: KI18n.i18n("Would you like to save the current game, so it can be continued later?")
        standardButtons: Kirigami.Dialog.Save | Kirigami.Dialog.Discard
        onDiscarded: continueLoad()
        onAccepted: {
            root.gp.saveGame()
            continueLoad()
        }
        function continueLoad() {
            if (filename) { root.loadFile(levelOrIndex, filename) }
            else { root.newGame(levelOrIndex) }
        }
    }

    // UI
    ColumnLayout {
        // Layout.margins: Kirigami.Units.gridUnit * 3
        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
            source: "qrc:/pumoku.svg"
            Layout.preferredWidth: app.isWideScreen ? root.height/2 : root.width/2
            Layout.preferredHeight: width
            sourceSize.width: width
            sourceSize.height: height
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            QQC2.Label {
                text: KI18n.i18n("New Sudoku:")
                font.bold: true
                padding: Kirigami.Units.mediumSpacing
                leftPadding: Kirigami.Units.largeSpacing
            }
            ColumnLayout {
                spacing: 1
                Repeater {
                    model: 4
                    delegate: PumokuListItem {
                        required property int index
                        text: Qqw.difficultyNames[index+1]
                        Layout.fillWidth: true
                        onClicked: root.promptSave(index + 1)
                    }
                }
            }
            QQC2.Label {
                text: KI18n.i18n("Import or enter:")
                font.bold: true
                padding: Kirigami.Units.mediumSpacing
                leftPadding: Kirigami.Units.largeSpacing
            }
            PumokuListItem {
                text: KI18n.i18nc("@action:button", "Import Sudoku …")
                Layout.preferredWidth: root.width
                onClicked: {
                    app.pageStack.layers.push("qrc:/Import.qml")
                }
            }
            PumokuListItem {
                text: KI18n.i18nc("@action:button", "Enter Sudoku …")
                Layout.preferredWidth: root.width
                visible: false
                onClicked: {
                }
            }
            QQC2.Label {
                text: KI18n.i18nc("@action:button", "Continue:")
                font.bold: true
                padding: Kirigami.Units.mediumSpacing
                leftPadding: Kirigami.Units.largeSpacing
                visible: gamesModel.count > 0
            }
            ColumnLayout {
                spacing:1
                Repeater {
                    model: gamesModel
                    delegate: PumokuListItem {
                        Layout.fillWidth: true
                        required property int index
                        required property string label
                        required property string filename
                        text: label
                        onClicked: root.promptSave(index, filename)
                    }
                }
            }
        }
    }
}
