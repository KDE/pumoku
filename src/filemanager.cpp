// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 Anders Lund <anders@alweb.dk>

#include "filemanager.h"
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QStandardPaths>
#include <QStringLiteral>

FileManager::FileManager(QObject *parent)
    : QObject(parent)
{
    m_appdatadir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

bool FileManager::saveGame(const QVariantMap &data)
{
    QString levelName = data[QStringLiteral("levelname")].value<QString>();
    QString sdate = QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMddThhmmss"));
    QString sjson = QStringLiteral(".json");
    QString name = levelName.append(QStringLiteral("_")).append(sdate).append(sjson);
    return saveGame(name, data);
}

bool FileManager::saveGame(const QString &name, const QVariantMap &data)
{
    QDir dir(m_appdatadir);
    if (!dir.exists()) {
        dir.mkpath(m_appdatadir);
        qInfo() << "created directory: " << m_appdatadir;
    }

    QJsonObject obj = QJsonObject::fromVariantMap(data);

    // fix broken lists
    QString board = QStringLiteral("board");
    QString solution = QStringLiteral("solution");
    QString values = QStringLiteral("values");
    QString pencilMarks = QStringLiteral("pencilmarks");
    QString errors = QStringLiteral("errors");
    QString stepCount = QStringLiteral("stepcount");

    QJsonArray boardArray;
    QJsonArray solutionArray;
    QJsonArray valuesArray;
    QJsonArray pencilMarksArray;
    QJsonArray errorsArray;
    QJsonArray stepCountArray;

    QList<int> boardList = data[board].value<QList<int>>();
    QList<int> solutionList = data[solution].value<QList<int>>();
    QList<int> valuesList = data[values].value<QList<int>>();
    QList<int> pencilMarksList = data[pencilMarks].value<QList<int>>();
    QList<int> errorsList = data[errors].value<QList<int>>();
    QList<int> stepCountList = data[stepCount].value<QList<int>>();

    int scl = stepCountList.length();
    for (int i = 0; i < 81; i++) {
        boardArray.push_back(QJsonValue(boardList[i]));
        solutionArray.push_back(QJsonValue(solutionList[i]));
        valuesArray.push_back(QJsonValue(valuesList[i]));
        pencilMarksArray.push_back(QJsonValue(pencilMarksList[i]));
        errorsArray.push_back(QJsonValue(errorsList[i]));
        if (i < scl) {
            stepCountArray.push_back(QJsonValue(stepCountList[i]));
        }
    }

    obj[board] = boardArray;
    obj[solution] = solutionArray;
    obj[values] = valuesArray;
    obj[pencilMarks] = pencilMarksArray;
    obj[errors] = errorsArray;
    obj[stepCount] = stepCountArray;
    // easy as pie ...

    QFile file(dir.filePath(name));
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(obj).toJson(QJsonDocument::Compact));
        return true;
    }
    qInfo() << "failed saving file: " << dir.filePath(name);
    return false;
}

QVariant FileManager::loadGame(const QString &name)
{
    QDir dir(m_appdatadir);
    QFile file = QFile(dir.filePath(name));
    if (file.open(QIODevice::ReadOnly)) {
        QVariant data = QJsonDocument::fromJson(file.readAll()).toVariant();
        return data;
    }
    // qDebug() << "file not found: " << name;
    return QVariant();
}

bool FileManager::deleteGame(const QString &name)
{
    QDir dir(m_appdatadir);
    QFile file = QFile(dir.filePath(name));
    return file.remove();
}

#include "moc_filemanager.cpp"
