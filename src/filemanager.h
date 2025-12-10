// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 Anders Lund <anders@alweb.dk>

#pragma once

#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QByteArray>
#include <QObject>
#include <QVariant>
#include <qqmlregistration.h>

/**
 * file management for pumoku
 * - Save/load game json files
 * - Delete game files
 *
 * Data is kept in QStandardDirs appdata directory
 *
 * Naming template for games: levelname_[datetime].json
 */

class FileManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    explicit FileManager(QObject *parent = nullptr);

    /**
     * Save game or return false
     */
    Q_INVOKABLE bool saveGame(const QString &name, const QVariantMap &data);

    /**
     * This overloaded fuction will generate a name like
     * [levelname]_[datetime].json
     */
    Q_INVOKABLE bool saveGame(const QVariantMap &data);

    /**
     * Load game and return it. If it fails, return an empy QVariantMap
     */
    Q_INVOKABLE QVariant loadGame(const QString &name);

    /**
     * Delete stored game or return false
     */
    Q_INVOKABLE bool deleteGame(const QString &name);

private:
    QString m_appdatadir;
};

#endif
