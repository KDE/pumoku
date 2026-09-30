// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.pumoku as Pumoku

// Check Board feature (hints menu)
// Check the board for value errors, and offer actions if there are any:
// Show, Scroll/step back, Reset game

Rectangle {
    width: drawer.width
    height: drawer.height
    color: Kirigami.Theme.backgroundColor

    property int errcount: 0

    ColumnLayout {
        width: drawer.width
        Layout.margins: Kirigami.Units.largeSpacing

        QQC2.Label {
            id: checkmsg
            text: msg()
            Layout.margins: Kirigami.Units.mediumSpacing
        }
        RowLayout {
            Layout.margins: Kirigami.Units.mediumSpacing
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            visible: errcount
            QQC2.Button {
                text: "Show me"
                onClicked: gameBoard.tmp_err_value = !gameBoard.tmp_err_value
                checkable: true
                checked: gameBoard.tmp_err_value
            }
            QQC2.Button {
                text: "Scroll back"
                onClicked: scrollBack()
            }
            QQC2.Button {
                text: "Reset game"
                onClicked: {
                    game.reset()
                    drawer.isOpen = false;
                    gameBoard.tmp_err_value = false;
                    drawerLoader.source = "";
                }
            }
        }
        RowLayout {
            Layout.margins: Kirigami.Units.mediumSpacing
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            QQC2.Button {
                text: "Close"
                onClicked: {
                    drawer.isOpen = false;
                    gameBoard.tmp_err_value = false;
                    drawerLoader.source = "";
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
        if (errcount < 1) return i18n("All is good!");
        else if (errcount > 1) return i18n("There are some errors.");
        else return i18n("Check board: ") + i18n("There is an error.");
    }

    function scrollBack() {
        while (errcount) {
            game.undo();
            countErrors();
            checkmsg.text = msg();
        }
    }
}
