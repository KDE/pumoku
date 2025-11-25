// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import org.kde.coreaddons
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.pumoku
import org.kde.pumoku.private

FormCard.FormCardPage {
    id: settingsPage
    title: i18nc("@title:window", "Settings")

    FormCard.FormHeader {
        title: i18nc("@title", "Game")
    }

    FormCard.FormCard {
        FormCard.FormComboBoxDelegate {
            displayMode: FormCard.FormComboBoxDelegate.ComboBox
            text: i18nc("@label:listbox", "Input method")
            textRole: "text"
            valueRole: "value"
            model: [{text: i18nc("@item:inlistbox", "Hybrid"), value: "hybrid" },
                    {text: i18nc("@item:inlistbox", "Digit, then cell"), value: "digitFirst"},
                    {text: i18nc("@item:inlistbox", "Cell, then digit"), value: "cellFirst"} ]
            currentIndex: Config.input_method == "hybrid" ? 0 : Config.input_method == "digitFirst" ? 1 : 2
            onCurrentValueChanged: Config.input_method = currentValue

        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Reset time with game")
            checked: Config.reset_time
            onCheckedChanged: Config.reset_time = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Clean up pencil marks when setting a cell value")
            checked: Config.cleanup_pencilmarks
            onCheckedChanged: Config.cleanup_pencilmarks = checked
        }
    }

    FormCard.FormHeader {
        title: i18nc("@title", "Highlight")
    }
    FormCard.FormCard {
        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Houses of a selected cell")
            checked: Config.houses
            onCheckedChanged: Config.houses = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Cells with active digit")
            checked: Config.digit_value
            onCheckedChanged: Config.digit_value = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Cells with active digit pencilmark")
            checked: Config.digit_pencilmark
            onCheckedChanged: Config.digit_pencilmark = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Logical errors in values")
            checked: Config.logical_error_value
            onCheckedChanged: Config.logical_error_value = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Logical errors in pencilmarks")
            checked: Config.logical_error_pencilmark
            onCheckedChanged: Config.logical_error_pencilmark = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Erasable cells with eraser active")
            checked: Config.erasable
            onCheckedChanged: Config.erasable = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Wrong values")
            checked: Config.error_value
            onCheckedChanged: Config.error_value = checked
        }
    }

}
