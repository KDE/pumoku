// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami


// Digit button with progress indicator.
// progress is a real between 0 and 1, determining the
// width of the indicator relative to the button.
Controls.Button {
    id: button
    checkable: true
    required property real progress
    property bool showProgress: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                            implicitContentHeight + topPadding + bottomPadding)
    padding: 6
    horizontalPadding: padding + 2
    // font.pixelSize: height*0.5

    background: Rectangle {
        implicitWidth: 40
        implicitHeight: 40

        visible: true //!parent.flat || button.down || button.checked || button.highlighted

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View

        color: progress == 1 ? Kirigami.Theme.positiveBackgroundColor : button.down || button.checked || button.highlighted ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.3) : Kirigami.Theme.alternateBackgroundColor

        border.color: button.down || button.checked || button.visualFocus ? Kirigami.Theme.focusColor : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.3)
        border.width: 1//button.visualFocus ? 2 : 1

        radius: Kirigami.Units.smallSpacing
        Rectangle {
            visible: showProgress && progress < 1
            height: parent.height-2
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 1
            topLeftRadius: parent.radius
            bottomLeftRadius: parent.radius
            width: (parent.width-2)*button.progress
            color: parent.color.darker(1.1)
        }
    }
    contentItem: Controls.Label {
        text: button.text
        font: button.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Kirigami.Theme.textColor //button.checked || button.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
            // button.flat && !button.down ? (button.visualFocus ? button.palette.highlight : button.palette.windowText) : button.palette.buttonText
    }
}
