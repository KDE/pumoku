// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.pumoku.private

Kirigami.ScrollablePage {
    id: pumokuMenu
    required property bool gameLoaded
    property Kirigami.ApplicationWindow app: applicationWindow()
    title: i18nc("@title:window", "Pumoku Menu")
    globalToolBarStyle: gameLoaded ? Kirigami.ApplicationHeaderStyle.Titles : Kirigami.ApplicationHeaderStyle.None

    ColumnLayout {
        Layout.margins: Kirigami.Units.gridUnit * 3
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
            QQC2.Label {
                text: i18n("New Sudoku:")
                font.bold: true
                padding: Kirigami.Units.mediumSpacing
            }
            ColumnLayout {
                spacing:0
                Repeater {
                    model: 4
                    delegate: QQC2.Button {
                        required property int index
                        Layout.preferredWidth: pumokuMenu.width * 0.7
                        text: Qqw.difficultyNames[index+1]
                        onClicked: {
                            app.generateSudoku(index+1, 0)
                            app.pageStack.layers.pop()
                        }
                    }
                }
            }
            QQC2.Label {
                text: i18n("Import or enter:")
                font.bold: true
                padding: Kirigami.Units.mediumSpacing
            }
            QQC2.Button {
                text: i18nc("@action:button", "Import Sudoku …")
                Layout.preferredWidth: pumokuMenu.width * 0.7
                onClicked: {
                    app.pageStack.layers.push("qrc:/Import.qml")
                }
            }
            QQC2.Button {
                text: i18nc("@action:button", "Enter Sudoku …")
                Layout.preferredWidth: pumokuMenu.width * 0.7
                enabled: false
                onClicked: {
                }
            }
        }
    }
}
