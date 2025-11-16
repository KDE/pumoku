// SPDX-License-Identifier: LGPL-2.1-or-later
// SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.pumoku
import org.kde.pumoku.private

Kirigami.Page {
    id: gameBoard
    title: "PuMoKu: " + levelName
    padding: 0
    width: root.width
    // globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None //gamePage.isCurrentPage && wideScreen ? Kirigami.ApplicationHeaderStyle.None : Kirigami.ApplicationHeaderStyle.ToolBar
    property bool wideScreen: applicationWindow().isWideScreen

    // BEGIN GAME
    property bool hasGame: false

    // props and init
    // The board consists of 9 blocks (grid layout) of 9 cells.
    // Bardmap maps the block cells to a linear game, 9 rows * 9 = 81 cells, zero based.
    // The mapping property in cells is bmidx.
    readonly property list<int> boardMap: [0,1,2,9,10,11,18,19,20,3,4,5,12,13,14,21,22,23,6,7,8,15,16,17,24,25,26,
    27,28,29,36,37,38,45,46,47, 30,31,32,39,40,41,48,49,50, 33,34,35,42,43,44,51,52,53,
    54,55,56,63,64,65,72,73,74, 57,58,59,66,67,68,75,76,77, 60,61,62,69,70,71,78,79,80];
    // lookup block base cells
    readonly property list<int> blockBase: [0,3,6,27,30,33,54,57,60];
    // to loop a block, starting at base cell, add:
    readonly property list <int> blockLoop: [0,1,2,9,10,11,18,19,20];

    // Properties below this line should be saved with game
    // Game properties
    property list<int> board: []
    property list<int> solution: []
    property list<int> values: []
    // PencilMark values in cells, pr boardmap index
    // Pencilmarks: Using an implicit binary mask, 0=None, then 2**digit-1 so that 1 is 2**0 = 1, 2 is 2**1 = 2 etc.
    // Pencilmarks displays have a mark property set to 2**index, which is equal to the above
    property list<int>pencilMarks: []
    // error values
    property list<int>errors: []

    property int givenCount: 0
    // qqwing difficulty, and as string
    property int level: 0
    property string levelName: ""

    property int hintCount: 0
    property int hintStatus: 0
    // value, pencilmark, undo, redo, reset, other
    // other is autopencilmarks, clear pencilmarks etc
    property list<int> stepCount: [0,0,0,0,0,0]

    // gameTimer.elapsed
    // undoStack
    // undoPos
    // properties (mentioned) above this comment should be saved with game.

    function save() {
        FileManager.saveGame({
            "board": board, "solution": solution, "values": values, "pencilmarks": pencilMarks, "errors": errors,
            "givencount": givenCount, "level": level, "levelname": levelName, "hintstatus": hintStatus,
            "hintcount": hintCount, "stepcount": stepCount, "elapsed": gameTimer.elapsed, "undopos": undoPos,
            "undoStack": undoStack
        })
    }

    function load(data) {
        // FIXME check!
        clear();
        bord = data.board;
        solution = data.solution;
        values = data.values;
        pencilMarks = data.pencilmarks;
        errors = data.errors
        givenCount = data.givencount;
        level = data.level;
        levelName = data.levelname;
        hintStatus = data.hintstatus;
        hineCount = data.hintcount;
        stepCount = data.stepcount;
        gameTimer.elapsed = data.elapsed - 1;
        undoPos = data.undopos;
        updoStack = data.undostack;
        finished = false;
        applicationWindow().setPage(gamePage);
        hasGame = true;
    }

    // properties supporting satistics and weighted finishing status
    // hint status bitmask
    property int hintStatusUsedHints: 1
    property int hintStatusPMLogicalErrorsVisible: 2
    property int hintStatusLogicalValueErrorsVisible: 4
    property int hintStatusValueErrorsVisible: 8
    property int hintStatusUsedAutoPM: 16
    property int hintStatusAutoSolved: 32

    property string finishHeader: ""
    property string finishText: ""
    property string finishMsg: ""
    property color finishColor: Kirigami.Theme.neutralBackgroundColor


    // Active digit (button pressed, digit highlighted in the board): 0 for none or 1-9
    property int currentDigit: 0
    property bool numberKeyActive: false

    // index of selected cell, and its block, row and colum
    property int currentCell: -1
    property int currentRow: -1
    property int currentColumn: -1
    property int currentBlock: -1

    property list<int> digitCounters: []
    property int valueCnt: 0
    property bool hasSolution: false
    property bool finished: false

    Component.onCompleted: {
        clear();
    }

    function clear() {
        values.length = 0;
        pencilMarks.length = 0;
        board.length = 0;
        errors.length = 0;

        values.length = 81;
        pencilMarks.length = 81;
        board.length = 81;
        errors.length = 81;

        digitCounters.length = 0;
        digitCounters.length = 10;

        currentCell = -1;
        currentRow = -1;
        currentColumn = -1
        currentBlock = -1;
        currentDigit = 0;
        numberKeyActive = false;

        finishHeader = "";
        finishText = "";
        finishMsg = "";
        finishColor = Kirigami.Theme.neutralBackgroundColor;

        givenCount = 0;
        valueCnt = 0;
        stepCount = [0,0,0,0,0,0];
        hintStatus = 0;

        gameTimer.elapsed = 0;
        gameTimer.stime = "00:00:00";
    }

    // reset game
    function reset() {
        currentCell = -1;
        currentRow = -1;
        currentColumn = -1
        currentBlock = -1;
        digitCounters.length = 0;
        digitCounters.length = 10;
        givenCount = 0;
        valueCnt = 0;
        stepCount = [0,0,0,0,stepCount[4],0]; // ???
        hintStatus = 0;
        for (let i=0; i < 81; i++) {
            values[i] = board[i];
            pencilMarks[i] = 0;
            errors[i] = 0;
            if (board[i]) {
                digitCounters[board[i]]++;
                givenCount++;
            }
        }
        if (Config.reset_time) {
            gameTimer.elapsed = 0;
            gameTimer.stime = "00:00:00";
        }
        finished = false;
        finishHeader = "";
        finishText = "";
        finishMsg = "";
        finishColor = Kirigami.Theme.neutralBackgroundColor;
    }

    function generateSudoku(difficulty, symmetry) {
        if (Qqw.generate(difficulty, symmetry)) {
            // console.log(Qqw.sudoku);
            // console.log(Qqw.solution);
            setGame(Qqw.sudoku, Qqw.solution);
            root.setPage(gamePage);
        }
    }

    function solveImported(sudoku) {
        let result = qqw.solve(sudoku);
        if (result == 1) {
            setGame(Qqw.sudoku, Qqw.solution)
            // root.setPage(gamePage);
        } else {
            return result;
        }
    }

    // int list args
    function setGame(puzzle,solved) {
        clear();
        let hasSolution = solved.length == 81;
        for (let i=0; i < 81; i++) {
            let v = puzzle[i];
            board[i] = v;
            values[i] = v;
            if (v) { givenCount++; }
            if (hasSolution) { solution[i] = solved[i]; }
            if (board[i]) { digitCounters[board[i]]++; }
        }
        level = Qqw.difficulty;
        levelName = Qqw.difficultyNames[level];
        finished = false;
        hasGame = true;
    }

    // UNDO/REDO
    // The stack is an array of arrays
    // An item contains a type identifier, an index, a count, undodata, redodata
    // An undoitem: [type,index,count,undodata,redodata]
    // Types are valuecell, pmcell, valueboard and pmboard.
    // Cell data is a single value, boards an array of 81 values.
    // IMPORTANT - cache the undo data BEFORE changing values, the new value is the redo data.
    // A int property - undoPos holds the position in the stack.
    // When adding an item, undoPos is set to array length -1
    // after the array is truncated.
    // Items are grouped by the count number in the third field, either 1 or two.
    // The first item in a group is the leader, causing the other items to added.
    // During undo/redo the count is read and that number of items applied.
    // To undo, the data at the pointer is inserted into the board, and the
    // position decremented.
    // To redo, the position is incremented, and the data at position is inserted.
    // If an action is equal to the last one - setting the same value, undo is used,
    // because that will work better and minimize overhead.
    readonly property int undoValueCell: 1
    readonly property int undoPMCell: 2
    readonly property int undoValueBoard: 3
    readonly property int undoPMBoard: 4
    property var undoStack: []
    property int undoPos: -1

    function addUndo (type, index, count, undodata, redodata) {
        while(undoStack.length > undoPos + 1) { undoStack.pop() }
        undoStack.push([type,index,count,undodata,redodata]);
        undoPos = undoStack.length -1;
    }
    // apply undo step at undoPos
    // if it's not undo, it's redo ;)
    function undoStep(isUndo) {
        if (undoPos < 0 || undoPos > undoStack.length) {
            console.log( "SERIOUS DRAINBAMAGE!! undoStep: " + undoPos + ", " + undoStack.length );
            return;
        }
        if (isUndo) { stepCount[2]++; } else { stepCount[3]++; }
        switch (undoStack[undoPos][0]) {
            case undoValueCell :
                let index = undoStack[undoPos][1];
                values[index] = undoStack[undoPos][isUndo?3:4];
                if (values[index] == 0 || values[index] == solution[index]){
                    errors[index] &= ~errValue;
                } else {
                    errors[index] |= errValue;
                }
                checkErrors(rowFromIndex(index),colFromIndex(index),blockFromIndex(index),index,values[index],errValueLogical);
                checkErrorsBoard(errPencilMarkLogical);
                updateDigitCounters();
                break;
            case undoValueBoard :
                undoStack[undoPos][isUndo?3:4].forEach((value,index)=>{values[index] = value});
                checkErrorsBoard(errValueLogical);
                checkErrorsBoard(errValue);
                updateDigitCounters();
                break;
            case undoPMCell :
                pencilMarks[undoStack[undoPos][1]] = undoStack[undoPos][isUndo?3:4];
                // reverseengineer the mark index and add one for a value
                // if 2**y = z, then y = log(z)/log(y)
                let val = (Math.log(Math.abs(undoStack[undoPos][3] - undoStack[undoPos][4]))/Math.log(2))+1;
                index = undoStack[undoPos][1];
                checkErrors(rowFromIndex(index),colFromIndex(index),blockFromIndex(index),index,val,errPencilMarkLogical);
                break;
            case undoPMBoard :
                undoStack[undoPos][isUndo?3:4].forEach((value,index)=>{pencilMarks[index] = value})
                checkErrorsBoard(errPencilMarkLogical);
                break;
        }
    }
    function undo() {
        let cnt = undoStack[undoPos][2];
        for (let i=0; i<cnt; i++ ) {
            undoStep(true);
            undoPos -= 1;
        }
    }
    function redo() {
        let cnt = undoStack[undoPos+1][2];
        for (let i=0; i<cnt; i++ ) {
            undoPos += 1;
            undoStep(false);
        }
    }
    property bool canRedo: undoStack.length > undoPos

    // Utilities
    function valueCount() {
        let count = 0;
        for(let i=0;i<81;i++) { if (values[i]>0) count++; }
        return count;
    }

    function digitCount(digit) {
        let count = 0;
        for(let i=0;i<81;i++) { if (values[i]==digit) count++; }
        return count;
    }

    function updateDigitCounters() {
        digitCounters.length = 0;
        digitCounters.length = 10;
        valueCnt = 0;
        for(let i=0;i<81;i++) {
            if (values[i]) {
                digitCounters[values[i]]++;
                valueCnt++;
            }

        }
    }

    function rowFromIndex(index) { return Math.trunc(index/9); }
    function colFromIndex(index) { return index%9; }
    function blockFromIndex(index) { return Math.trunc(boardMap.indexOf(index)/9); }
    function copyOfList(list){
        let ret = [];
        ret.push(...list)
        // for (let i=0;i<list.length;i++) { ret.push(list[i]); }
        return ret;
    }

    // we can erase cells that are not given, and has a value or pencilmark
    function erasable(index) { return (board[index] == 0 && (values[index] > 0 || pencilMarks[index] > 0)); }

    // Qml weirdness: can't be done from button menu
    function goHome() {root.setPage(mainMenu);}

    // Gamechangers - event handlers for buttons/taps and functions to apply value changes

    // clean pencilmarks when a value have been set to a cell,
    // this means removing conflicting marks in houses that
    // the cell is part of.
    // returns count of changed marks // TODO consider returning an array of changed fields, for optimizing undo further.
    function cleanPencilMarks (row, col, block, bmindex, digit) {
        const m = 2**(digit-1) // pencilmark bit for digit is 2^(zerobased value)
        const rb = row * 9; // row base bmindex
        const bb = blockBase[block]
        let count = 0;
        // loop through each house
        for (let i = 0; i < 9; i++) {
            // block
            const b = bb+blockLoop[i]; // bmindex of block cell
            if (b!= bmindex && (pencilMarks[b] & m)) {
               pencilMarks[b] &= ~m;
               count++;
            }
            // row
            const r = rb + i; // bmindex of row cell
            if (r != bmindex && (pencilMarks[r] & m)) {
                pencilMarks[r] &= ~m;
                count++;
            }
            // column
            const c = i * 9 + col; // bmindex of col cell
            if (c != bmindex && (pencilMarks[c] & m)) {
                pencilMarks[c] &= ~m;
                count++;
            }
        }
        return count
    }

    readonly property int valueTValue: 1
    readonly property int valueTMark: 2

    // Set a value for cellTapped() or numberKeyClicked()
    // - if we cant use automatic undo/redo
    property int lastIndex: 0;
    property int lastVal: 0;
    property int lastType: 0;
    function setValue(index, row, col, block, value, type) {
        const isEqualAction = index == lastIndex && value == lastVal && type == lastType;
        lastIndex = index;
        lastVal = value;
        lastType = type;

        if (board[index] > 0) { return }
        // automatic undo/redo: If the undo action at hand contains
        // same type, cell and value, just undo or redo as fit.
        if (undoStack.length && isEqualAction) {
            // the same type, index and value, just undo() or redo().
            let undoType = type == valueTValue ? undoValueCell : undoPMCell;
            let checkPos = undoStack.length - 1;
            // in case of cell value, undo count may be 2 (if pencilMarks were cleaned)
            if (undoStack[checkPos][2] == 2) {
                checkPos -=1;
            }
            // check 1: same undoType and cell
            if (undoStack[checkPos][0] == undoType /*&& undoStack[checkPos][1] == index*/) {
                // check 2: same value in redo field of undo item.
                if ((type == valueTValue && undoStack[checkPos][4] == value) ||
                (type == valueTMark && undoStack[checkPos][4] & value)) { // <= OPTIONAL ERROR
                    // undo if cell contains value, else redo
                    if ((type == valueTValue && values[index] == value) ||
                    (type == valueTMark && pencilMarks[index] & value))  {
                        undo();
                    } else {
                        redo();
                    }
                    return;
                }
            }
        }
        // console.log("SKIPPED automatic undo/redo");
        // DONE automatic undo/redo
        if (type == valueTValue) {
            if (values[index] == value) {
                digitCounters[value]--;
                value = 0;
            } else if (values[index]) {
                digitCounters[values[index]]--;
                errors[index] &= ~errValue;
            }
            let undodata = values[index];
            values[index] = value;
            if (value) { digitCounters[value]++; }
            if (value != 0 && solution[index] != value) {
                errors[index] |= errValue;
                // if (Config.error_value)
                //     hintStatus |= errValue;
            } else {
                errors[index] &= ~errValue;
            }
            addUndo(undoValueCell,index,1,undodata,values[index]);
            // cleanPencilMarks() returns the number of cells fixed
            // only add undo item if anything was done.
            if (value > 0 && Config.cleanup_pencilmarks) {
                let undodata = copyOfList(pencilMarks);
                if (cleanPencilMarks(row, col, block, index, value)) {
                    undoStack[undoPos][2]=2;
                    addUndo(undoPMBoard,index,2,undodata,copyOfList(pencilMarks));
                }
            }
            let errcnt = checkErrors(row, col, block, index, value, errValueLogical);
            valueCnt = valueCount();
            stepCount[0]++;

            // no errors and 81 filled cells => game finished :)
            if (errcnt == 0 && valueCnt == 81) {
                    finish();
            }
        }
        else if (type == valueTMark) {
            // if value is 0, clear marks, else toggle
            let undodata = pencilMarks[index];
            let newmark = 0;
            if (value > 0) {
                let m = 2**(value-1); // value is 1-9, mark is [0-8]**2
                newmark = pencilMarks[index];
                (newmark & m) === m ? newmark &= ~m : newmark |= m;
            }
            pencilMarks[index] = newmark;
            addUndo(undoPMCell,index,1,undodata,pencilMarks[index]);
            checkErrors(row, col, block, index, value, errPencilMarkLogical)
            stepCount[1]++;
        }
    }

    // remove all pencilmarks
    function clearPencilMarks()  {
        let undodata = copyOfList(pencilMarks);
        for (let i=0; i < 81; i++) {
            pencilMarks[i] = 0;
        }
        addUndo(undoPMBoard,0,1,undodata,copyOfList(pencilMarks));
        checkErrorsBoard(errPencilMarkLogical);
        stepCount[5]++;
    }

    // generate pencilmarks:
    // for each house, first collect seen numbers in a pm bitmask,
    // then add those to the pm of the house cells
    function generatePencilMarks() {
        let undodata = copyOfList(pencilMarks);
        // clearPencilMarks();
        const all = 511; // 1|2|4|8|16|32|64|128|256
        for (let i=0; i < 81; i++) {
            if (values[i] == 0)
                pencilMarks[i] = all;
        }
        for (let i=0; i<9; i++) {
            const ir = i*9; // index of first row cell
            let rowMark = 0;
            let colMark = 0;
            let blkMark = 0;
            // 1. collect values from each house
            for (let j=0; j<9; j++) {
                let c = ir+j; // cell index
                rowMark |= 2**(values[c]-1);
                c = boardMap[c];
                blkMark |= 2**(values[c]-1);
                colMark |= 2**(values[i+j*9]-1);
            }
            // 2. remove pm's accordingly
            for (let j=0; j<9; j++) {
                let c = ir+j; // cell index
                if (!values[c]) pencilMarks[c] &= ~rowMark;
                c =  boardMap[c];
                if (!values[c]) pencilMarks[c] &= ~blkMark;
                c = i+j*9; // cell index in col
                if (!values[c]) pencilMarks[c] &= ~colMark;
            }
        }

        addUndo(undoPMBoard,0,1,undodata,copyOfList(pencilMarks));
        hintStatus |= hintStatusUsedAutoPM;
        stepCount[5]++;
    }

    // Finishing
    // property int hintStatusUsedHints: 1
    // property int hintStatusPMLogicalErrorsVisible: 2
    // property int hintStatusLogicalValueErrorsVisible: 4
    // property int hintStatusValueErrorsVisible: 8
    // property int hintStatusUsedAutoPM: 16
    // property int hintStatusAutoSolved: 32
    // property string finishHeader: ""
    // property string finishText: ""
    // property string finishMsg: ""
    // property color finishColor: Kirigami.Theme.neutralBackgroundColor

    function finish() {
        if (countBoardErrors() > 0)
            return;

        finished  = true;
        currentDigit = 0;
        currentBlock = -1;
        currentRow = -1;
        currentColumn = -1;
        currentCell = -1;
        let stepcnt = 0;
        for(let i=0;i<5;i++)
            stepcnt += stepCount[i];
        let stepmsg = i18n("using " + stepcnt + " steps ");

        if (hintStatus & hintStatusAutoSolved) {
            finishColor = Kirigami.Theme.alternateBackgroundColor;
            finishHeader = i18n("There is your solution.")
            finishText = i18n("You gave in after " + stepcnt + " steps");
            finishMsg = "Automatically solved. ";
            finishMsg += i18n("Hints: ") + hintCount;
        } else if (hintCount || hintStatus & hintStatusUsedAutoPM) {
            finishColor = Kirigami.Theme.neutralBackgroundColor;
            finishHeader = i18n("Well done!");
            finishText = i18n("You finished this " + levelName + " suduko (with a bit of help) " + stepmsg + "in ");
            if (hintStatus & hintStatusUsedAutoPM) {
                finishMsg = i18n("Auto pencilmarks used. ")
            }
            finishMsg += i18n("Hints: ") + hintCount;
        } else {
            finishColor = Kirigami.Theme.positiveBackgroundColor;
            finishHeader = i18n("CONGRATULATIONS!!");
            finishText = i18n("You finished this " + levelName + " suduko with no hints or help " + stepmsg + "in ");
            finishMsg = i18n("Well done!")
        }

        // save statistics data - time, level
        // play a sound?
        drawer.open();
    }

    // help and hints
    function solve() {
        digitCounters  = [];
        digitCounters.length = 10;
        for (let i=0; i<81; i++) {
            values[i] = solution[i];
            digitCounters[values[i]]++;
        }
        hintStatus |= hintStatusAutoSolved;
        finish();
    }

    function solveCell (index) {
        if (currentCell < 0) { return }
        setValue(index, rowFromIndex(index), colFromIndex(index), blockFromIndex(index), solution[index], valueTValue);
        hintCount++;
    }

    // Event handlers
    function cellTapped(row, col, block, index) {
        if (finished) return;
        if (btnErase.checked) {
            if (erasable(index)) {
                if (values[index]) {
                    setValue(index, row, col, block, 0, valueTValue);
                } else {
                    setValue(index, row, col, block, 0, valueTMark);
                }
            }
            return;
        } else if (btnPencilMarks.checked && numberKeyActive) {
            if (values[index] == 0) {
                setValue(index, row, col, block, currentDigit, valueTMark)
            }
        } else if (numberKeyActive) {
            if (board[index] == 0) {
                setValue(index, row, col, block, currentDigit, valueTValue);
            }
        } else if (currentCell != index) {
            // select cell
            currentDigit = values[index];
            currentCell = index;
            currentRow = row;
            currentColumn = col;
            currentBlock = block;
        } else {
            // deselect cell
            currentDigit = 0;
            currentCell = -1;
            currentRow = -1;
            currentColumn = -1;
            currentBlock = -1;
        }
    }

    function numberKeyClicked(index, checked, btn) {
        if (finished) return;
        let key = index + 1;
        if (btn.checked && currentDigit == key) {
            // digit, cell mode, toggle
            currentDigit = 0;
        } else if (currentCell > -1 ) {
            // cell - digit mode
            if (btnPencilMarks.checked) {
                setValue(currentCell, currentRow, currentColumn, currentBlock, key, valueTMark)
            } else {
                setValue(currentCell, currentRow, currentColumn, currentBlock, key, valueTValue);
            }
            currentDigit = 0;
            //btn.toggle();
        } else {
            currentDigit = key;
        }
        numberKeyActive = btn.checked;
    }

    function eraseClicked() {
        if (currentCell > -1 && erasable(currentCell)) {
            setValue(currentCell, currentRow, currentColumn, currentBlock, 0, valueTValue);
            btnErase.toggle();
        }
    }

    // Error checking
    // Error type bits:
    readonly property int errValue: 2048 // 2**11
    readonly property int errValueLogical: 1024 // 2**10
    readonly property int errPencilMarkLogical: 512 // 2**9
    // TODO the above appears in hintStatus if seen and displayed.
    // 2**[0-8] are individual pencilmark errors

    // check houses of a cell for logical value errors
    // and logical pencilmark errors.
    // returns the number of errors
    function checkErrors(row, col, block, bmindex, val, type) {
        // console.log("checking for errors " + type)
        let found = [[],[],[]];
        const rb = row * 9; // row base bmindex
        const br = (block - block%3) * 3; // block base row
        const bc = block%3 * 3; // block base col
        const bb = blockBase[block];
        // in case of pencilmark logical error, the error value should be the pencilmark bit ([0-8]**2)
        // this will avoid pencilmark errors wrongly being cleared, and allow to show the error
        // in the pencilmark cell (should I want to)
        // when looking a cell with this type of errer, the error will be > 0 and < errPencilMarkLogical (512)
        const err = type == errPencilMarkLogical ? 2**(val-1) : type;
        // if type is errPencilMarkLogFIXME ical, only set error if mark is present (else remove).
        // this is only checked for that type, not for errValueLogical
        // this allows to unset the mark if there is no error.
        // true if not a mark, or mark is set in cells pencilmarks
        let hasMark = type == errValueLogical ? true : (pencilMarks[bmindex] & err);
        for (let i = 0; i < 9; i++) {
            // block
            let c = bb + blockLoop[i];
            let idx = (type == errValueLogical) ? c : bmindex;
            if (values[c] > 0 && values[c] == val && hasMark) {
                found[0].push([idx,err]);
            } else if (hasMark) {
                errors[idx] &= ~err;
            }
            // row
            c = rb + i; // bmindex of row cell
            idx = (type == errValueLogical) ? c : bmindex;
            if (values[c] > 0 && values[c] == val && hasMark) {
                found[1].push([idx,err]);
            } else if (hasMark) {
                errors[idx] &= ~err;
            }
            // column
            c = i * 9 + col; // bmindex of col cell
            idx = (type == errValueLogical) ? c : bmindex;
            if (values[c] > 0 && values[c] == val && hasMark) {
                found[2].push([idx,err]);
            } else if (hasMark) {
                errors[idx] &= ~err;
            }
        }
        let cnt = 0;
        let minErrs = type == errPencilMarkLogical ? 0 : 1;
        found.forEach((value) => {
            if(value.length > minErrs) {
                value.forEach((value) => {
                    errors[value[0]] |= value[1];
                cnt++
                })
            }
        });
        if (cnt) {
            // console.log("checkErrors: found " + cnt)
            setHintStatusErr (type);
        }
        return cnt;
    }

    // check entire board for errors:
    //
    // Purpose: regenerate errors after undo/redo. Maybe it is better to just store errors with undo data?
    // would make the size of a common undo item at least 340 ints, possibly 500 - but be much easier.
    //
    // Loop over the cells and act according to error type
    // value errors: just set if present (present value that differs from sulution), the easy one.
    // logical value errors: call checkErrors for each cell that has a value, or unset.
    // pencilmark logical errors: for each digit (0-8) call checkErrors if there is no cell value,
    // and the mark is set in cells pencilmarks, else unset. TODO consider this again.
    function checkErrorsBoard(type) {
        // console.log("checking board errors (" + type + ")" );
        for (let i=0; i<81; i++) {
            errors[i] &= ~type;
            if (type == errValue) {
                if (values[i] > 0 && values[i] != solution[i]) {
                    errors[i] |= type;
                    setHintStatusErr (type);
                }
                else{
                    errors[i] &= ~type;
                }
            } else if (type == errValueLogical && values[i]) {
                checkErrors(rowFromIndex(i), colFromIndex(i), blockFromIndex(i), i, values[i], type);
            } else if (type == errPencilMarkLogical) {
                for (let j=0; j<9; j++) {
                    if (!values[i] && pencilMarks[i] & 2**j) {
                        checkErrors(rowFromIndex(i), colFromIndex(i), blockFromIndex(i), i, j+1, type);
                    } else {
                        errors[i] &= ~(2**j);
                    }
                }
            }
        }
    }

    // add bit to hintStatus if errors of type is displayed.
    function setHintStatusErr (type) {
        // console.log("setting hintstatus for error: " + type)
        switch (type) {
            case errValue:
                if (Config.error_value)
                    hintStatus |= type;
            break;
            case errValueLogical:
                if (Config.logical_error_value)
                    hintStatus |= type;
            break;
            case errPencilMarkLogical:
                if (Config.logical_error_pencilmark)
                    hintStatus |= type;
        }
    }

    // check for value errors (wrong solution) at finish
    function countBoardErrors() {
        let errcnt = 0;
        for (let i=0;i<81;i++) {
            if (values[i] != solution[i]) {
                errcnt++;
            }
        }
        return errcnt;
    }

    Timer {
        id: gameTimer
        running: applicationWindow().active && gamePage.isCurrentPage && !finished
        repeat: true
        interval: 1000

        property int elapsed: 0
        property string stime: "00:00:00"
        onTriggered: {
            elapsed++;
            var h,m,s;
            h=Math.floor(elapsed/3600).toString().padStart(2,"0");
            m=Math.floor((elapsed%3600)/60).toString().padStart(2,"0");
            s=Math.floor(elapsed%60).toString().padStart(2,"0");
            stime = h + ":" + m + ":" + s;
        }
    }
    // END GAME

    // UI
    // Game board
    Rectangle {
        id: boardContainer
        width: wideScreen ? gameBoard.height : gameBoard.width
        height: width
        color: Kirigami.Theme.backgroundColor
        Rectangle {
            id: bgbd
            anchors.centerIn: parent
            property real pw: Math.floor((Math.min(gameBoard.width, gameBoard.height)-12)/9)*9+12
            width: pw //Math.min(gamePage.width,gamePage.height)
            height: width
            color: Kirigami.Theme.backgroundColor
            border.width: 1
            border.color: Kirigami.Theme.textColor

            Rectangle {
                anchors.centerIn: parent
                // force width to fit the 9X9 grid to avoid weird painting errors
                // 10 pix are used as block and cell boarders
                width: Math.floor((parent.width-10)/9)*9+10
                height: width
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                color: Kirigami.Theme.textColor

                GridLayout {
                    id: boardLayout
                    columns: 3
                    columnSpacing: 2
                    rowSpacing: 2
                    anchors.fill: parent
                    uniformCellHeights: true
                    uniformCellWidths: true


                    // blocks
                    Repeater {
                        model: 9
                        GridLayout {
                            required property int index
                            columns: 3
                            columnSpacing: 1
                            rowSpacing: 1
                            Layout.fillWidth: true
                            uniformCellHeights: true
                            uniformCellWidths: true
                            // cells
                            Repeater {
                                model: 9
                                delegate: Rectangle {
                                    required property int index
                                    Layout.fillWidth: true
                                    property int bmidx: boardMap[index + parent.index*9]
                                    property int rowIndex: bmidx > 0 ? bmidx/9 : 0
                                    property int columnIndex: index%3 + (parent.index%3)*3
                                    property int pencilMark: 0
                                    implicitHeight: width
                                    // color for various highlights: selected cell or digit.
                                        // logical errors
                                    color: (Config.logical_error_value && (errors[bmidx] & errValueLogical) === errValueLogical) ||
                                           // (Config.logical_error_pencilmark && (errors[bmidx] & errPencilMarkLogical) === errPencilMarkLogical)  ?
                                           (Config.logical_error_pencilmark && errors[bmidx] > 0 && errors[bmidx] < errPencilMarkLogical)  ?
                                        Kirigami.Theme.negativeBackgroundColor :
                                        // value errors
                                        (Config.error_value && (errors[bmidx] & errValue) === errValue) ? Kirigami.Theme.visitedLinkBackgroundColor :
                                        // erasable cells while erase button is checked
                                        btnErase.checked && Config.erasable && board[bmidx] == 0 && (values[bmidx] > 0 || pencilMarks[bmidx] > 0) ?
                                        Kirigami.Theme.neutralBackgroundColor :
                                        // values with number key active
                                        (Config.digit_value && values[bmidx] > 0 && values[bmidx] == currentDigit) || bmidx == currentCell ?
                                        Kirigami.Theme.highlightColor :
                                        // highlight pencilmarks with number key active
                                        Config.digit_pencilmark && values[bmidx] == 0 && (pencilMarks[bmidx] & (2**(currentDigit-1))) === 2**(currentDigit-1) ?
                                        Kirigami.Theme.positiveBackgroundColor :
                                        // highlight houses related to selected cell
                                        Config.houses && (rowIndex == currentRow || columnIndex == currentColumn || parent.index == currentBlock) ?
                                        Kirigami.Theme.activeBackgroundColor :
                                        Config.alternateBlockBackgrounds && parent.index%2 == 0 ? Kirigami.Theme.backgroundColor : Kirigami.Theme.alternateBackgroundColor
                                    Text {
                                        text: values[bmidx] > 0 ? values[bmidx] : ""
                                        anchors.centerIn: parent
                                        color: Kirigami.Theme.textColor
                                        font.pixelSize: parent.width*0.8
                                        font.bold: values[bmidx] == board[parent.bmidx]
                                    }
                                    TapHandler { onTapped: cellTapped(rowIndex, columnIndex, parent.parent.index, bmidx); }
                                    // pencil marks
                                    Rectangle {
                                        anchors.fill: parent
                                        visible: 0 == values[parent.bmidx]
                                        color: parent.color
                                        Layout.fillWidth: true
                                        GridLayout {
                                            columns: 3
                                            rowSpacing: 0
                                            columnSpacing: 0
                                            width: parent.width
                                            Repeater {
                                                model: 9
                                                delegate: QQC2.Label {
                                                    required property int index
                                                    property int mark: 2**(index)
                                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                                    font.pixelSize: Math.floor(parent.width/4)
                                                    text: index + 1
                                                    opacity: (pencilMarks[parent.parent.parent.bmidx] & mark) === mark ? 1 : 0
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // button board
    Rectangle {
        id: bottomContainer
        anchors.top: wideScreen ? boardContainer.top : boardContainer.bottom
        anchors.left: wideScreen ? boardContainer.right : boardContainer.left
        width: wideScreen ? root.width - boardContainer.width : root.width
        height: wideScreen ? gamePage.height : gamePage.height - boardContainer.height
        color: Kirigami.Theme.backgroundColor
        Rectangle {
            id: bottomTitle
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Header
            color: Kirigami.Theme.backgroundColor
            width: parent.width
            height: bottomHeading.height + 1
            visible: wideScreen

            QQC2.ToolButton {
                id: drawerBtn
                anchors.verticalCenter: parent.verticalCenter
                icon.name: "menu_new-symbolic"
                onClicked: { applicationWindow().globalDrawer.drawerOpen = true; }
            }

            Kirigami.Heading {
                anchors.left: drawerBtn.right
                id: bottomHeading
                padding: Kirigami.Units.mediumSpacing
                level: 2
                text: gameBoard.title// "pomuko: " + gameBoard.levelName
            }
            Rectangle {
                width: parent.width
                height: 1
                color: parent.color.darker(1.1)
                anchors.bottom: parent.bottom
            }
        }
        Rectangle {
            id: progressBar
            width: parent.width /*- Kirigami.Units.largeSpacing*4*/
            anchors.top: bottomTitle.visible ? bottomTitle.bottom : parent.top
            // anchors.horizontalCenter: parent.horizontalCenter
            height: Kirigami.Units.largeSpacing
            color: Kirigami.Theme.positiveBackgroundColor
            property real sW: width/81
            Rectangle {
                id: progressGivens
                height: parent.height
                anchors.left: parent.left
                width: parent.sW*givenCount
                color: Kirigami.Theme.positiveBackgroundColor.darker(1.2)
            }
            Rectangle {
                id: progressSolved
                height: parent.height
                anchors.left: progressGivens.right
                width: parent.sW*(valueCnt - givenCount)
                color: Kirigami.Theme.positiveBackgroundColor.darker(1.1)
            }

        }
        RowLayout {
            anchors.top: progressBar.bottom
            id: buttonBoard
            width: parent.width// - Kirigami.Units.largeSpacing
            // height: parent.height// - Kirigami.Units.largeSpacing
            Layout.margins: Kirigami.Units.largeSpacing

            // undo/redo/hint
            ColumnLayout {
                Layout.topMargin: Kirigami.Units.largeSpacing
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.fillWidth: true
                Layout.fillHeight: true
                QQC2.Button {
                Layout.fillWidth: true
                    id: btnUndo
                    text: i18n("Undo")
                    // text: "Fortryd"
                    icon.name: "edit-undo-symbolic"
                    onClicked: undo();
                    enabled: undoPos > -1;
                }
                QQC2.Button {
                    Layout.fillWidth: true
                    id: btnRedo
                    text: i18n("Redo")
                    // text: "Gendan"
                    icon.name: "edit-redo-symbolic"
                    onClicked: redo();
                    enabled: undoPos < undoStack.length-1
                }
                QQC2.Button {
                    Layout.fillWidth: true
                    id: btnHint
                    text: i18n("Hint")
                    icon.name: "games-hint-symbolic"
                    onClicked: hintsMenu.open()
                    QQC2.Menu {
                        id: hintsMenu
                        QQC2.MenuItem {
                            text: i18n("Solve cell")
                            onTriggered: solveCell(currentCell)
                            enabled: currentCell > -1 && board[currentCell] === 0
                        }
                        QQC2.MenuItem {
                            text: i18n("Set pencilmarks")
                            onTriggered: gameBoard.generatePencilMarks()
                        }
                    }
                }

            }
            // number keys
            GridLayout {
                id: numberKeys
                Layout.topMargin: Kirigami.Units.largeSpacing
                columns: 3

                Repeater {
                    model: 9

                    delegate: DigitButton {
                        required property int index
                        property int value: index+1
                        progress: (digitCounters[value])/9
                        checkable: false
                        checked: currentDigit == value
                        Layout.fillWidth: true
                        Layout.minimumWidth: implicitHeight
                        Layout.preferredWidth: implicitHeight
                        Layout.preferredHeight: implicitHeight
                        //autoExclusive: true
                        text: value
                        onClicked: { numberKeyClicked(index, checked, this) }
                    }
                }
            }

            ColumnLayout {
                Layout.rightMargin: Kirigami.Units.largeSpacing
                Layout.topMargin: Kirigami.Units.largeSpacing
                Layout.fillWidth: true
                QQC2.Button {
                Layout.fillWidth: true
                    id: btnPencilMarks
                    checkable: true
                    text: i18n("Pencil")
                    icon.name: "open-for-editing-symbolic"
                }
                QQC2.Button {
                Layout.fillWidth: true
                    id: btnErase
                    checkable: true
                    text: i18n("Erase")
                    // text: "Visk ud"
                    icon.name: "tool_eraser-symbolic"
                    onClicked: eraseClicked();
                }
                QQC2.Button {
                Layout.fillWidth: true
                    id: btnGame
                    text: i18n("Game")
                    icon.name: "application-menu-symbolic"
                    onClicked: gameMenu.open()
                    QQC2.Menu {
                        id: gameMenu
                        QQC2.MenuItem {
                            text: i18n("Reset game")
                            onTriggered: gameBoard.reset()
                        }
                        QQC2.MenuItem {
                            text: i18n("Clear pencilmarks")
                            onTriggered: gameBoard.clearPencilMarks()
                        }
                        QQC2.MenuItem {
                            text: i18n("Give up")
                            onTriggered: {
                                gameBoard.clear();
                                gameBoard.goHome();
                            }
                        }
                        QQC2.MenuItem {
                            text: i18n("Solve game")
                            onTriggered: { dialogSolve.open() }
                            Kirigami.PromptDialog {
                                id: dialogSolve
                                title: i18n("Are you sure??")
                                subtitle: i18n("you loose any changes you have made, and can't solve the puzzele on your own!")
                                standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
                                onAccepted: gameBoard.solve()
                            }
                        }
                    }

                }
            }
        }
        Rectangle {
            anchors.bottom: bottomContainer.bottom
            width: bottomContainer.width
            height: childrenRect.height
            color: Kirigami.Theme.backgroundColor
            QQC2.Label {
                Layout.alignment: Qt.AlignHCenter
                padding: Kirigami.Units.largeSpacing
                id: timerDisplay
                text: "Time: " + gameTimer.stime
            }
        }

        // display for hints, finish info/congrats
        Rectangle {
            id: drawer
            width: parent.width
            height: bottomTitle.visible ? parent.height - bottomTitle.height : parent.height
            y: parent.height -1// + 1
            property bool isOpen: false
            states: [
                State {
                    name: "open"; when: drawer.isOpen
                    PropertyChanges { target: drawer; y: bottomTitle.visible ? bottomTitle.height + 1 : 0; }
                },
                State {
                    name: "closed"; when: !drawer.isOpen
                    PropertyChanges { target: drawer; y: parent.height + 1; }
                }
            ]

            transitions: Transition { SmoothedAnimation { target: drawer; property: "y"; velocity: 3000 } }

            TapHandler {} // QML will let the event drop through if not present.

            function open() { isOpen = true; }
            function close() { isOpen = false }

            color: finishColor

            ColumnLayout {
                width: parent.width
                Layout.margins: Kirigami.Units.mediumSpacing
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    Layout.alignment: Qt.AlignHCenter
                    padding: 10
                    // bottomPadding:10
                    text: finishHeader
                }
                QQC2.Label {
                    Layout.maximumWidth: parent.width - parent.spacing*2
                    width: parent.width
                    Layout.alignment: Qt.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: finishText
                }
                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    font.pointSize: 20
                    text:  gameTimer.stime
                }
                QQC2.Label {
                    visible: finishMsg.length
                    Layout.alignment: Qt.AlignHCenter
                    text: finishMsg
                }
                RowLayout {
                    Layout.leftMargin: Kirigami.Units.mediumSpacing
                    Layout.rightMargin: Kirigami.Units.mediumSpacing
                    Layout.alignment: Qt.AlignHCenter
                    QQC2.Button  {
                        text: i18n("Another " + levelName)
                        onClicked: { generateSudoku(level, 0); drawer.close(); }
                    }
                    QQC2.Button {
                        text: i18n("Main menu")
                        onClicked: { goHome(); drawer.close(); }
                    }
                }
            }
        }
    }
}
