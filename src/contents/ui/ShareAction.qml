// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick
import org.kde.purpose as Purpose
import org.kde.kirigami as Kirigami

/**
 * Action that allows an user to share data with other apps and service
 * installed on their computer. The goal of this high level API is to
 * adapt itself for each platform and adopt the native component.
 */
Kirigami.Action {
    id: shareAction
    property Kirigami.ApplicationWindow app: applicationWindow()

    // text: i18nc("@action Share link to play current game on sudokuexchange.com", "Share")
    icon.name: "emblem-shared-symbolic"
    property var inputData: ({})

    onTriggered: {
        const shareMenuComponent = Qt.createComponent("org.kde.pumoku", "ShareMenu");
        const menu = shareMenuComponent.createObject(app.overlay, {
            inputData: shareAction.inputData,
            applicationWindow: app,
            title: i18nc("@title:menu", "Share sudokuexchange.com link")
        }) as ShareMenu;
        menu.popup();
    }

}
