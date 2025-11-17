// SPDX-License-Identifier: LGPL-2.1-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.pumoku.private

Kirigami.Page {
    id: importPage
    title: i18n("Import sudoku")

    ColumnLayout {
        width: parent.width
        Layout.margins: Kirigami.Units.largeSpacing
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
            }
        }
        QQC2.Label {
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width-parent.margins*2
            wrapMode: Text.WordWrap
            text: i18n("Enter or paste a string of 81 characters. 1-9 for given cells, zero or any single non-numeric character except space will do for blanks cells. PuMoKu will check that the sudoku is solvable and calculate the level.\n\nLine breaks and spaces are silently removed, so that you can enter one row pr line with some optional whitespace.")
        }
        Kirigami.InlineMessage {
            id: message
            type: Kirigami.MessageType.Error
            showCloseButton: true
            width: parent.width
            text: ""
        }
        RowLayout {
            width: parent.width
            spacing: Kirigami.Units.largeSpacing
            Layout.alignment: Qt.AlignRight
            QQC2.Button {
                text: i18n("Cancel")
                onClicked: applicationWindow().pageStack.layers.pop()
            }
            QQC2.Button {
                text: i18n("Import")
                property list<int> importboard: []
                onClicked: {
                    let s = importString.text
                    s = s.replace(/[\s\n]/g,"");
                    s = s.replace(/\D/,"0");

                    if (s.length != 81) {
                        console.log("Wrong string length: " + s.length)
                        message.text = i18n("The provided string is not exactly 81 characters after cleanup. Please fix.")
                        message.visible = true
                    } else {
                        let importboard = [];
                        for(let i=0; i<81; i++) {
                            importboard.push(parseInt(s[i]));
                        }
                        if (Qqw.solve(importboard) == 1) {
                            gamePage.setGame(Qqw.sudoku, Qqw.solution);
                            applicationWindow().setPage(gamePage);
                            applicationWindow().pageStack.layers.pop();
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
