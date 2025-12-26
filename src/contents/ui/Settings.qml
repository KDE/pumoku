// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import org.kde.coreaddons
import QtQuick
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
        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Reset time with game")
            checked: Config.reset_time
            onCheckedChanged: Config.reset_time = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check", "Clean up pencil marks when setting a cell value")
            checked: Config.cleanup_pencilmarks
            onCheckedChanged: {
                Config.cleanup_pencilmarks = checked
                gamePage.highlightConfigChanged()
            }
        }
    }

    FormCard.FormHeader {
        title: i18nc("@title of a section describing which kind of cells should be highlighted", "Highlight")
    }
    FormCard.FormCard {
        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check describing which kind of cells should be highlighted", "Houses of a selected cell")
            checked: Config.houses
            onCheckedChanged: Config.houses = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check describing which kind of cells should be highlighted", "Cells with active digit")
            checked: Config.digit_value
            onCheckedChanged: Config.digit_value = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check describing which kind of cells should be highlighted", "Cells with active digit pencilmark")
            checked: Config.digit_pencilmark
            onCheckedChanged: Config.digit_pencilmark = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check describing which kind of cells should be highlighted", "Logical errors in values")
            checked: Config.logical_error_value
            onCheckedChanged: Config.logical_error_value = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check describing which kind of cells should be highlighted", "Logical errors in pencilmarks")
            checked: Config.logical_error_pencilmark
            onCheckedChanged: {
                Config.logical_error_pencilmark = checked
                gamePage.highlightConfigChanged()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check describing which kind of cells should be highlighted", "Erasable cells with eraser active")
            checked: Config.erasable
            onCheckedChanged: Config.erasable = checked
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18nc("@option:check describing which kind of cells should be highlighted", "Wrong values")
            checked: Config.error_value
            onCheckedChanged: Config.error_value = checked
        }
    }

}
