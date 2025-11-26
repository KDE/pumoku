// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 Anders Lund <anders@alweb.dk>

#pragma once

#ifndef QQW_H
#define QQW_H

#include <klocalizedstring.h>
#include "qqwing.hpp"
#include <QObject>
#include <qqmlregistration.h>


/**
 * Interface to qqwing, in place of the cli program it comes with.
 * This is simplified, no argument parsing or printing output.
 * Just generating a board with given difficulty and optionally
 * symmetry as specified.
 * Aditionally, get one solve step given the current status of the game,
 * for the purpose of giving a textual hint, of solving a step.
 */

class Qqw: public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:

    explicit Qqw(QObject *parent = nullptr);

    /**
     * A list of difficulties as a strings.
     * The first item ([0]) should be skipped in a menu.
     * This way, the index is equal to the corresponding enum value.
     */
    Q_PROPERTY(QStringList difficultyNames MEMBER m_difficultyNames CONSTANT)

    /**
     * A list of symmetries as strings.
     */
    Q_PROPERTY(QStringList symmetries MEMBER m_symmetries CONSTANT)

    /**
     * generate sudoku
     */
    Q_INVOKABLE bool generate(SudokuBoard::Difficulty, SudokuBoard::Symmetry);

    /*
     * solve a user provided sudoku
     */
    enum SolveStatus {
        Failed,
        OK,
        Multiple
    };
    Q_ENUM(SolveStatus)
    Q_INVOKABLE Qqw::SolveStatus solve(const QList<int> &sudoku);

    Q_PROPERTY(QList<int> sudoku MEMBER m_sudoku)
    Q_PROPERTY(QList<int> solution MEMBER m_solution)
    Q_PROPERTY(int symmetry MEMBER m_symmetry)
    Q_PROPERTY(int difficulty MEMBER m_difficulty)
    // error message from solving
    Q_PROPERTY(QString message MEMBER m_message)

    /**
     * get a solve step
     */
    // Q_INVOKABLE(??? getSolveStep(const QList<int> &board))

private:
    QList<int> m_sudoku;
    QList<int> m_solution;
    QString m_message;
    QStringList m_difficultyNames;
    QStringList m_symmetries;
    int m_difficulty;
    int m_symmetry;
};

#endif
