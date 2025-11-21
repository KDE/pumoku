// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.pumoku.private

Kirigami.Page {
    title: i18nc("@title:window", "Main menu")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        width: gamePage.wideScreen ? parent.height : parent.width
        Layout.margins: Kirigami.Units.gridUnit * 3
        // anchors.fill: parent
        Kirigami.Heading {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("Wellcome to PuMoKu")
            level: 1
        }
        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
            source: "qrc:/pumoku.svg"
            width: gamePage.wideScreen ? parent.height/2 : parent.width/2
            height: width
            sourceSize.width: width
            sourceSize.height: height
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            QQC2.Button {
                id: buttonSolve
                text: i18n("Solve a sudoku")
                Layout.preferredWidth: parent.parent.width * 0.7
                onClicked: sudokuMenu.open();
                QQC2.Menu {
                    id: sudokuMenu
                    Repeater {
                        // Skipping difficulty UNKNOWN (at [0]) means the difficulty value is index + 1.
                        model: Qqw.difficultyNames.length - 1
                        QQC2.MenuItem {
                            required property int index
                            text: Qqw.difficultyNames[index+1]
                            onTriggered: { gamePage.generateSudoku(index+1, 0); root.setPage(gamePage) }
                        }
                    }
                }
            }
            QQC2.Button {
                id: buttonContinue
                text: i18n("Continue ...")
                Layout.preferredWidth: parent.parent.width * 0.7
                onClicked: root.setPage(gamePage)
                visible: gamePage.hasGame
            }
            QQC2.Button {
                id: buttonImport
                text: i18n("Import ...")
                Layout.preferredWidth: parent.parent.width * 0.7
                onClicked: root.pageStack.layers.push("qrc:/Import.qml")
            }
        }
    }
}
