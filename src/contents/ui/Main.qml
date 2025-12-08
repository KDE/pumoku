// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.config as Config

Kirigami.ApplicationWindow {
    id: root
    property bool isWideScreen: width > height
    controlsVisible: (gamePage.visible && isWideScreen && !gamePage.tabletMode) ? false : true
    title: i18n("PuMoKu")

    minimumWidth: Kirigami.Units.gridUnit * 24
    minimumHeight: minimumWidth

    width: 400
    height: 800

    Config.WindowStateSaver {
	configGroupName: 'main'
    }

    Component.onCompleted: {
        if(!gamePage.hasGame)
            pageStack.layers.push("qrc:/MainMenu.qml", {gameLoaded: false})
    }

    property bool acceptClose: false
    onClosing: (close) => {
        if (gamePage.hasGame && !acceptClose) {
            closePrompt.open();
            close.accepted = false
        } else {
            close.accepted = true
        }
    }

    Kirigami.PromptDialog {
        id: closePrompt
        title: i18nc("@action:button", "Give Up Active Game?")
        subtitle: i18n("Pumoku does not save your game yet. Closing the app means giving up.")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            acceptClose = true;
            Qt.quit();
        }

    }

    function setPage (page) {
        pageStack.clear()
        pageStack.push(page)
    }

    function generateSudoku(difficulty, symmmetry) {
        gamePage.generateSudoku(difficulty, symmmetry)
    }

    GamePage {
        id: gamePage
    }

    pageStack {
        globalToolBar {
            style: Kirigami.ApplicationHeaderStyle.ToolBar
        }
        initialPage: gamePage
    }

}
