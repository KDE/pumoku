// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.ki18n
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.pumoku.private

// Check Board feature (hints menu)
// Check the board for value errors, and offer actions if there are any:
// Show, Scroll/step back, Reset game

Rectangle {
    id: root
    width: parent.width
    height: parent.height
    required property GamePage gp
    required property PumokuEngine game
    color: Kirigami.Theme.backgroundColor

    property int errcount: 0

    ColumnLayout {
        width: parent.width
        Layout.margins: Kirigami.Units.largeSpacing

        QQC2.Label {
            id: checkmsg
            text: root.msg()
            Layout.margins: Kirigami.Units.mediumSpacing
        }
        RowLayout {
            Layout.margins: Kirigami.Units.mediumSpacing
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            visible: root.errcount
            QQC2.Button {
                text: KI18n.i18nc("@action:button", "Show me")
                onClicked: root.gp.tmp_err_value = !root.gp.tmp_err_value
                checkable: true
                checked: root.gp.tmp_err_value
            }
            QQC2.Button {
                text: KI18n.i18nc("@action:button, undo recursively", "Scroll back")
                onClicked: root.scrollBack()
            }
            QQC2.Button {
                text: KI18n.i18nc("@action:button", "Reset game")
                onClicked: {
                    root.gp.resetGame()
                    root.gp.tmp_err_value = false;
                    root.gp.closeDrawer();
                }
            }
        }
        RowLayout {
            Layout.margins: Kirigami.Units.mediumSpacing
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            QQC2.Button {
                text: KI18n.i18nc("@action:button", "Close")
                onClicked: {
                    root.gp.closeDrawer()
                    root.gp.tmp_err_value = false;
                }
            }
        }
    }


    Component.onCompleted: countErrors()

    function countErrors() {
        errcount = 0;
        game.errors.forEach((v) => {if(v) errcount++});
    }

    function msg() {
        if (errcount < 1) return KI18n.i18n("All is good!");
        else return KI18n.i18np("There is an error", "There are some errors.", errcount);
    }

    function scrollBack() {
        while (errcount) {
            game.undo();
            countErrors();
            checkmsg.text = msg();
        }
    }
}
