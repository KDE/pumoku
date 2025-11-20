// SPDX-License-Identifier: GPL-2.1-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.config as Config

Kirigami.ApplicationWindow {
    id: root
    property bool isWideScreen: width > height
    controlsVisible: (gamePage.isCurrentPage && isWideScreen) ? false : true
    title: i18n("PuMoKu")

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: minimumWidth //Kirigami.Units.gridUnit * 32
    // my oneplus 6t phone display size unscaled
    // width: 360
    // height: 780

    Config.WindowStateSaver {
	configGroupName: 'main'
    }

    Component.onCompleted: {
        setPage(mainMenu);
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
        title: i18n("Give up active game?")
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

    globalDrawer: Kirigami.GlobalDrawer {
        enabled: pageStack.layers.depth == 1
        // isMenu: true
        collapseButtonVisible: false
        actions: [
            Kirigami.Action {
                text: i18n("Main menu")
                icon.name: "go-home-large-symbolic"
                onTriggered: root.setPage(mainMenu)
            },
            // Kirigami.Action {
            //     text: i18n("Statistics")
            //     icon.name: "office-chart-line"
            //     // onTriggered: root.pageStack.pushDialogLayer(settingsPage)
            // },
            // Kirigami.Action {
            //     text: i18n("Help")
            //     icon.name: "help-contents-symbolic"
            //     // onTriggered: root.pageStack.pushDialogLayer(settingsPage)
            // },
            Kirigami.Action {
                text: i18n("Settings")
                icon.name: "settings-configure-symbolic"
                onTriggered: root.pageStack.layers.push("qrc:/Settings.qml")
            },
            Kirigami.Action {
                text: i18n("About PuMoKu")
                icon.name: "help-about"
                onTriggered: root.pageStack.layers.push("qrc:/About.qml")
            },
            Kirigami.Action {
                visible: !Kirigami.Settings.isMobile
                text: i18n("Quit")
                icon.name: "application-exit"
                onTriggered: Qt.quit()
            }

        ]
    }


    GamePage {
        id: gamePage
    }

    MainMenu {
        id: mainMenu
    }
    pageStack.initialPage: gamePage

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

}

