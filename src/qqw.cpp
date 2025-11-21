// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 Anders Lund <anders@alweb.dk>

#include "qqw.h"
#include <iostream>
// #include "qqwing.hpp"

Qqw::Qqw(QObject *parent) : QObject(parent)
{
    m_difficultyNames = QStringList { i18n("UNKNOWN"), i18n("Simple"), i18n("Easy"), i18n("Intermediate"), i18n("Expert") };
    m_symmetries = QStringList { i18n("None"), i18n("Rotate 90°"), i18n("rotate 180°"), i18n("Mirror"), i18n("Flip"), i18n("Random") };
    m_difficulty = SudokuBoard::UNKNOWN;
    m_symmetry = SudokuBoard::NONE;
    m_sudoku = QList<int>(81,0);
    m_solution = QList<int>(81,0);
}

bool Qqw::generate(SudokuBoard::Difficulty difficulty, SudokuBoard::Symmetry symmetry)
{

    // initialize random generator
    srand(unsigned(time(nullptr)));

    SudokuBoard *sb = new SudokuBoard();
    sb->setRecordHistory(true);
    sb->setLogHistory(false);
    bool done = false;
    while (!done) {
        if (sb->generatePuzzleSymmetry(symmetry)) {
            int solutions = sb->countSolutions();
            sb->solve();
            if (solutions == 1 && difficulty == sb->getDifficulty()) {
                done = true;
            }
        }
    }
    // FIXME change these away from const in qqwing?
    sb->solve();
    m_sudoku.clear();
    m_solution.clear();
    const int *p = sb->getPuzzle();
    const int *s = sb->getSolution();
    for(int i=0; i<81; i++) {
        m_sudoku << p[i];
        m_solution << s[i];
    }
    m_difficulty = difficulty;
    m_symmetry = symmetry;
    delete sb;
    return true;
}



Qqw::SolveStatus Qqw::solve(const QList<int> &board)
{
    m_symmetry = SudokuBoard::NONE;
    SudokuBoard *sb = new SudokuBoard();
    const int *d = board.data();
    int dd[81];
    for (int i=0; i<81; i++) { dd[i] = d[i]; }
    if (sb->setPuzzle(dd)) {
        sb->setRecordHistory(true);
        sb->solve();
        m_difficulty = sb->getDifficulty();
        m_sudoku = board;
        if (sb->hasUniqueSolution()) {
            sb->solve();
            m_solution.clear();
            const int *s = sb->getSolution();
            for(int i=0; i<81; i++) {
                m_solution << s[i];
            }
            m_message = i18n("Looking good. Difficulty: ") + m_difficultyNames[m_difficulty];
            return Qqw::SolveStatus::OK;
        }
        m_message = i18n("The provided sudoku does not have a unique solution.");
        m_sudoku = board;
        return Qqw::SolveStatus::Multiple;
    }
    m_message = i18n("The provided sudoku is not solvable");
    return Qqw::SolveStatus::Failed;
}

