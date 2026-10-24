// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.ki18n
import org.kde.kirigami as Kirigami
import org.kde.pumoku

Kirigami.Page {
    id: root
    title: KI18n.i18nc("@title:window", "Import Sudoku")
    required property GamePage gp
    property Kirigami.ApplicationWindow aw: applicationWindow()

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.largeSpacing
        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width - Kirigami.Units.largeSpacing*2
            Layout.preferredHeight: Kirigami.Units.gridUnit*10
            QQC2.TextArea {
                id: importString
                width: parent.width
                height: parent.height
                font.family: "mono"
                wrapMode: Text.Wrap
                inputMethodHints: Qt.ImhPreferNumbers
            }
        }
        QQC2.Label {
            Layout.fillWidth: true
            // Layout.maximumWidth: parent.width-parent.margins*2
            wrapMode: Text.WordWrap
            text: KI18n.i18nc("Please use UTF character EN DASH (U+2013) for number range", "Enter or paste a string of 81 characters. 1–9 for given cells, 0 or any single non-numeric character except space will do for blanks cells. PuMoKu will check that the Sudoku is solvable and calculate the level.\n\nLine breaks and spaces are silently removed, so that you can enter one or more rows per-line with some optional whitespace.")
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            id: message
            type: Kirigami.MessageType.Error
            showCloseButton: true
            text: ""
        }
        QQC2.CheckBox{
            id: saveCheck
            text: KI18n.i18nc("@button:title","Save current game")
            visible: root.gp.hasGame
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing
            Layout.alignment: Qt.AlignRight
            QQC2.Button {
                text: KI18n.i18nc("@action:button", "Cancel")
                onClicked: root.aw.pageStack.layers.pop()
            }
            QQC2.Button {
                text: KI18n.i18nc("@action:button", "Import")
                property list<int> importboard: []
                onClicked: {
                    let s = importString.text
                    s = s.replace(/[\s\n]/g,"");
                    s = s.replace(/\D/,"0");

                    if (s.length !== 81) {
                        console.log("Wrong string length: " + s.length)
                        message.text = KI18n.i18n("The provided string is not exactly 81 characters after cleanup. Please amend.")
                        message.visible = true
                    } else {
                        let importboard = [];
                        for(let i=0; i<81; i++) {
                            importboard.push(parseInt(s[i]));
                        }
                        if (Qqw.solve(importboard) === 1) {
                            if (root.gp.hasGame && saveCheck.checked) {
                                root.gp.saveGame()
                            }
                            root.gp.setGame(Qqw.sudoku, Qqw.solution);
                            root.aw.pageStack.layers.clear();
                        } else {
                            message.text = Qqw.message;
                            message.visible = true;
                        }
                    }
                }
            }
        }
    }
}
