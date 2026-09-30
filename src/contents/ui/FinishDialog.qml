// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.pumoku.private


Rectangle {
    width: drawer.width
    height: drawer.height

    ColumnLayout {
        id: drawerContent
        width: parent.width
        Layout.margins: Kirigami.Units.mediumSpacing
        QQC2.Label {
            id: l_header
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: 20
            Layout.topMargin: Kirigami.Units.largeSpacing
        }
        QQC2.Label {
            id: l_text
            Layout.maximumWidth: parent.width - Kirigami.Units.largeSpacing*4
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
        }
        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: 18
            text: timer.stime
        }
        QQC2.Label {
            id: l_msg
            visible: text.length
            Layout.alignment: Qt.AlignHCenter
        }
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.mediumSpacing
            Layout.bottomMargin: Kirigami.Units.largeSpacing
            Layout.alignment: Qt.AlignHCenter
            QQC2.Button  {
                text: i18nc("@action:button, %1 is level name", "Another %1", game.levelName)
                onClicked: {
                    gameBoard.generateSudoku(game.level, 0)
                }
            }
        }
    }

    Component.onCompleted: setup()

    function setup() {
        let stepcount = 0;
        game.stepCount.forEach((value) => stepcount += value );

        if (game.hintStatus & game.hintStatusAutoSolved) {
            color = Kirigami.Theme.alternateBackgroundColor;
            l_header.text = i18n("There is your solution")
            l_text.text = i18nc("%1 is step count", "You gave in after %1 steps.", stepcount);
            l_msg.text = i18nc("%1 is hint count", "Automatically solved. Hints: %1.", game.hintCount);
        } else if (game.hintCount || game.hintStatus & game.hintStatusUsedAutoPM) {
            color = Kirigami.Theme.neutralBackgroundColor;
            l_header.text = i18n("Well done!");
            l_text.text = i18nc("%1 is step count", "You solved this sudoku (with a bit of help) in %1 steps.", stepcount);
            if (game.hintStatus & game.hintStatusUsedAutoPM) {
                l_msg.text = i18n("Auto pencilmarks used.") + " ";
            }
            l_msg.text += i18nc("%1 is hint count", "Hints: %1.", game.hintCount);
        } else {
            color = Kirigami.Theme.positiveBackgroundColor;
            l_header.text = stepcount > 81 - game.givenCount ? i18n("CONGRATULATIONS!!") : i18n("PURE PERFECTION!!");
            l_text.text = i18nc("%1 is step count", "You solved this sudoku with no hints or help in %1 steps.", stepcount);
            l_msg.text = i18n("Well done!")
        }
    }
}
