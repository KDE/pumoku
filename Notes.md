SPDX-License-Identifier: CC0-1.0
SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

# Project vision

The goal with PoMuKo is to create a beautiful, usable, well functioning classic suduko solving app aimed at (plasma) mobile.

- Use Kirigami and QtQuick
- Use Plasma theming throughout, with colors predominantly from Kirigami Theme
- Good configurability with sane defaults
- Stellar suduko solving features
- fully translatable, using i18n & friends throughout the code

# Licencing

All code is GPL-2.1 or later
Other files (this file, graphics, other) ? CC-BY-SA-4.0

# Contributing

Anyone is wellcome to contribute to translations, with (nice!) comments and suggestions, and help with code, according to KDE rules and guidelines.

# Notes for translators

- Please familiarize yourself with sudoku terminology and mechanics. Reading **Sudoku basics** below should suffice, but consider the terminology in your language.
- Button labels must be kept short, since there is limited space on mobile screens. 5-6 characters at most.

# Sudoku basics

The classic Soduko puzzle board consists of 9x9 cells, which can be seed as

- 9 rows of 9 cells
- 9 columns of 9 cells
- 9 3x3 blocks in three rows

A block, row or column is known as a *house*.

The houses are commonly identified as \<type\>\<index\>: Row 2, Column 7, Block 3, or for short: R2, C7, B3.

Each cell is a member of 3 houses: a block, a row and a cell as illustrated below (the houses of the cell with the **X**):

     _ _ _ _ _ _ _ _ _
    |     |     |b b b|
    |c c c|c c c|b X b|
    |_ _ _|_ _ _|b b b|
    |     |     |  r  |
    |     |     |  r  |
    |_ _ _|_ _ _|_ r _|
    |     |     |  r  |
    |     |     |  r  |
    |_ _ _|_ _ _|_ r _|

The puzzle comes with number of given cell values (1-9), and the object is to fill out the rest of the cells such that

- there is only one instance of a digit (1-9) in each house
- the solution is unique


When looking at a puzzle, an unfilled cell is a candidate for a digit that is not present in other of that cells' houses.

Using pencilmarks or notes: mark candidates of a cell with a small digot or dot depicting that the cell is a candidate for that digit.

Depending on the difficulty of the puzzle, solving strategies spans from simple to very advanced. Examples includes

- singles: For example: a digit can only be placed in one cell of a house, due to values in other houses.
- hiddens: Two of more cells in a house shares a set of candidates, that means the other cells in that hous can't contain those digits.
- chains: a pattern of candidates in a set of cells means that a value can be set, or one or more cells in related houses can't contain either candidate.
-
-
-
- wild guessing

Look for sudopedia on the www for inspiration!

# Sudoku mechanics

## Logical errors (values)

These appears if there are two or more instances of a digit within a house.

Checked each time a value is set, and displayed if desired.

## Errors (values)

These appears if a cell value differs from the correct solution.

Checked each time a value is set, and displayed if desired.

Displaying errors is cheating, but may be desirable while learning/practising, or in rare events where there can be a non-solution due to swappable values.

## Logical errors (pencilmarks)

These appears if a pencilmark is set in a cell where the corresponding value appears in either house.

# PoMuKo mechanics

## The game board and data

Due to the ways QML and Qt Layouts works, I elected to define the board by block, each block containing 9 cells by row (3x3).

This leads to a conflict because the games are defined in a stream, bu row.

To overcome this, the gameboard component contains a hardcoded index (`boardMap`), mapping the linear game stream to the blocks.

The block, row and column of any cell can be calculated from the map index, which is the `bmidx` property of each cell, but are also present in cells as properties, and in game data when a cell is selected: `currentRow`, `currentColumn`, `currentBlock`. Aditionally, the bmidx of a selected cell is available as property `currentCell`. Those are set to `-1` when no cell is selected, and are nessecary for house highlightning ao.

The game data has five lists, linear by row:

- **board**: The given sudoku puzzle
- **solution**: the solution, calculated by qqwing
- **values**: Initially synced with board, user input values are added here.
- **errors**: calculated errors in a bitmask: value errors, logical value errors, logical pencilmark errors
- **pencilMarks**: pencilmarks in a bit mask, 2^digit so that 0 = no mark, 1 = 1, 2=2, 3=4 etc.

Value errors, logical value errors and pencilmark logical errors are calculated for each cell house when a value/mark is set, and displayed according to configuration.

## Input methods

### Cell first

- You select a cell, and then press a digit key to set a value.
- If the Pencilmarks button is checked, this will set the mark
- Houses of the cell will be highlighted, if desired.

### Digit first

- First select a digit (button will appear checked).
- Tap the cell to set the value, if pencilmark button is checked a mark is set.
- Cells with the corresponding value will be highlighted if desired.

### Hybrid (default)

You can do either. To use cell first, all digit buttons needs to be unchecked. To use digit first, no cell can be selected.

## Eraser

- The eraser works with both input methods.
- Only cells that are not given will have their values erased.
- With a cell selected, clicking the eraser will erase that cell, value or mark as present.
- With a digit button selected, tapping a cell will erase any value or a corresponding mark as present.

## Buttons

### Undo/redo

The undo/redo buttons will be enabled when applicable, and pressing will undo/redo accordingly.

### Game menu

### Hints menu

## File management - TODO

Autosave current unfinished game and inject it at startup.

Optionally (auto-)save games if new games are started while the current is unfinished.

Saving a game includes:

- puzzle
- values
- marks
- errors
- selected cell
- active digit
- undo stack

## Implementation

A file manager component (C++) that can

- list directory
- check if a file with given name exists
- remove files
- save files
- read files

Files will be saved to the XDG local data directory, provided by QStandardDirs

From QML, call the file manager as needed, and load games from disk.
