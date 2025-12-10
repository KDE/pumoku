// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.ItemDelegate {
    id: customButton
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Button
    topInset: 0
    bottomInset: 0
    contentItem: QQC2.Label {
        text: customButton.text
        padding: Kirigami.Units.mediumSpacing
        horizontalAlignment: Qt.AlignHCenter
    }
    background: Rectangle {
        color: parent.hovered ? Kirigami.Theme.hoverColor : Kirigami.Theme.backgroundColor
    }
}
