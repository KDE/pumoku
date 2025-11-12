// SPDX-License-Identifier: GPL-2.1-or-later
// SPDX-FileCopyrightText: 2025 Anders Lund <anders@alweb.dk>

#pragma once

#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <qqmlregistration.h>

/**
 * file management for pumoku
 * - Save/load games
 * - Autosave a current game when quitting
 * - List available saved games  for continuation
 * - Delete games when finished
 * - Maintain a link to any current game
 *
 * Data is kept in QStandardDirs appdata directory
 *
 * Naming template for games: levelname_[number].json
 */

class FileManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    explicit FileManager(QObject *parent = nullptr);

    Q_INVOKABLE void saveGame(QVariantMap data);

    Q_INVOKABLE QVariantMap loadGame(QString path);

    Q_INVOKABLE bool deleteGame(QString path);

    Q_INVOKABLE QStringList listAvailableGames();
};

#endif
