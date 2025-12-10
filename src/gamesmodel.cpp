// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 Anders Lund <anders@alweb.dk>

#include "gamesmodel.h"
#include <KFormat>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QLocale>
#include <QStandardPaths>

GamesModel::GamesModel(QObject *parent)
    : QAbstractListModel(parent)
{
    init();
}

void GamesModel::init()
{
    m_games = QStringList();
    m_dir = QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    QStringList filter;
    filter << QStringLiteral("*_*.json");
    QStringList files = m_dir.entryList(filter, QDir::NoFilter, QDir::Time);
    for (const QString &filename : files) {
        addGame(filename);
    }
    m_count = files.count();
}

int GamesModel::rowCount(const QModelIndex &) const
{
    return m_games.count();
}

Qt::ItemFlags GamesModel::flags(const QModelIndex &)
{
    return Qt::ItemIsSelectable | Qt::ItemIsEnabled;
}

QHash<int, QByteArray> GamesModel::roleNames() const
{
    return {{FilenameRole, "filename"}, {LabelRole, "label"}};
}

QVariant GamesModel::data(const QModelIndex &index, int role) const
{
    // qDebug() << createLabel(m_games.at(index.row()));
    switch (role) {
    case LabelRole:
        return createLabel(m_games.at(index.row()));
    case FilenameRole:
        return m_games[index.row()];
    default:
        return {};
    }
}

void GamesModel::addGame(const QString &filename)
{
    beginInsertRows(QModelIndex(), 0, 0);
    m_games.append(filename);
    endInsertRows();
    m_count = m_games.count();
    Q_EMIT countChanged(m_count);
}

void GamesModel::removeGame(const QString &filename, const int &rowIndex)
{
    if (m_dir.exists(filename)) {
        m_dir.remove(filename);
        beginRemoveRows(QModelIndex(), rowIndex, rowIndex);
        m_games.remove(m_games.indexOf(filename));
        endRemoveRows();
        m_count = m_games.count();
        Q_EMIT countChanged(m_count);
    }
}

QString GamesModel::createLabel(QString filename) const
{
    QString sDate(KFormat().formatRelativeDateTime(QFile(m_dir.filePath(filename)).fileTime(QFileDevice::FileModificationTime), QLocale::ShortFormat));
    return filename.slice(0, filename.lastIndexOf(QStringLiteral("_"))).append(QStringLiteral(" - ")).append(sDate);
}

int GamesModel::count() const
{
    return m_count;
}

QBindable<int> GamesModel::bindableCount()
{
    return QBindable<int>(&m_count);
}

#include "moc_gamesmodel.cpp"
