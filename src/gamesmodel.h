// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 Anders Lund <anders@alweb.dk>

#pragma once

#ifndef GAMESMODEL_H
#define GAMESMODEL_H

#include <QAbstractListModel>
#include <QBindable>
#include <QDir>
#include <QStringList>
#include <qqmlregistration.h>

/**
 * List games in appdata directory that are saved
 * for continuation.
 */

class GamesModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    GamesModel(QObject *parent = nullptr);

    Q_INVOKABLE void init();
    Q_INVOKABLE int rowCount(const QModelIndex &) const override;
    Qt::ItemFlags flags(QModelIndex &);

    enum Roles {
        FilenameRole = Qt::UserRole,
        LabelRole
    };

    QHash<int, QByteArray> roleNames() const override;
    Qt::ItemFlags flags(const QModelIndex &);
    QVariant data(const QModelIndex &index, int role) const override;
    Q_INVOKABLE void addGame(const QString &filename);
    Q_INVOKABLE void removeGame(const QString &filename, const int &rowIndex);

    Q_PROPERTY(int count READ count NOTIFY countChanged BINDABLE bindableCount);
    int count() const;
    QBindable<int> bindableCount();

Q_SIGNALS:
    void countChanged(int);

private:
    QString createLabel(QString filename) const;
    QStringList m_games;
    QDir m_dir;
    Q_OBJECT_BINDABLE_PROPERTY(GamesModel, int, m_count, &GamesModel::countChanged)
};

#endif
