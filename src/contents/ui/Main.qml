// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
// import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.config as Config

Kirigami.ApplicationWindow {
    id: root
    property bool isWideScreen: width > height
    controlsVisible: (gamePage.visible && isWideScreen && !gamePage.tabletMode) ? false : true

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: minimumWidth

    width: 400
    height: 800

    Config.WindowStateSaver {
	configGroupName: 'main'
    }

    Component.onCompleted: {
        if (!gamePage.loadGame('current.json')) {
            pageStack.layers.push("qrc:/MainMenu.qml", {gameLoaded: false})
        }
    }

    property bool acceptClose: false
    onClosing: (close) => {
        if (gamePage.hasGame) {
            gamePage.saveGame('current.json') || console.log('saving game failed');
            close.accepted = true;
        } else {
            FileManager.deleteGame("current.json");
        }
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
