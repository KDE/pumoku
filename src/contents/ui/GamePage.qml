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
    title: "PuMoKu: " + game.levelName
    padding: 0
    width: root.width
    // globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None //gamePage.isCurrentPage && wideScreen ? Kirigami.ApplicationHeaderStyle.None : Kirigami.ApplicationHeaderStyle.ToolBar

    PumokuEngine {
        id: game
    }

    property bool wideScreen: applicationWindow().isWideScreen

    property bool hasGame: !game.finished
    property bool numberKeyActive: false

    // Qml weirdness: can't be done from button menu
    function goHome() {root.setPage(mainMenu);}

    function generateSudoku(difficulty, symmetry) {
        if (Qqw.generate(difficulty, symmetry)) {
            setGame(Qqw.sudoku, Qqw.solution);
        }
    }

    function setGame(puzzle, solution) {
        game.setGame(puzzle, solution);
        root.setPage(gamePage);
        timer.reset();
    }

     // Event handlers FIXME move part of the code to game engine?
    function cellTapped(row, col, block, index) {
        if (game.finished) return;
        if (btnErase.checked) {
            if (game.erasable(index)) {
                if (game.values[index]) {
                    game.setValue(index, row, col, block, 0, game.valueTValue);
                } else {
                    game.setValue(index, row, col, block, 0, game.valueTMark);
                }
            }
            // return;
        } else if (btnPencilMarks.checked && numberKeyActive) {
            if (game.values[index] == 0) {
                game.setValue(index, row, col, block, game.currentDigit, game.valueTMark)
            }
        } else if (numberKeyActive) {
            if (game.board[index] == 0) {
                game.setValue(index, row, col, block, game.currentDigit, game.valueTValue);
            }
        } else if (game.currentCell != index) {
            // select cell
            game.currentDigit = game.values[index];
            game.currentCell = index;
            game.currentRow = row;
            game.currentColumn = col;
            game.currentBlock = block;
        } else {
            // deselect cell
            game.currentDigit = 0;
            game.currentCell = -1;
            game.currentRow = -1;
            game.currentColumn = -1;
            game.currentBlock = -1;
        }
        if (game.finished) finish();
    }

    function numberKeyClicked(index, checked, btn) {
        if (game.finished) return;
        let key = index + 1;
        if (btn.checked && game.currentDigit == key) {
            // digit, cell mode, toggle
            game.currentDigit = 0;
        } else if (game.currentCell > -1 ) {
            // cell - digit mode
            const type = btnPencilMarks.checked ? game.valueTMark : game.valueTValue;
            game.setValue(game.currentCell, game.currentRow, game.currentColumn, game.currentBlock, key, type);
            game.currentDigit = 0;
        } else {
            game.currentDigit = key;
        }
        numberKeyActive = btn.checked;
        if (game.finished) finish();
    }

    function eraseClicked() {
        if (game.currentCell > -1 && game.erasable(currentCell)) {
            game.setValue(game.currentCell, game.currentRow, game.currentColumn, game.currentBlock, 0, game.valueTValue);
            btnErase.toggle();
        }
    }

    property string finishHeader: ""
    property string finishText: ""
    property string finishMsg: ""
    property color finishColor: Kirigami.Theme.neutralBackgroundColor

    function finish() {
        let stepcnt = 0;
        game.stepCount.forEach((value) => stepcnt += value )
        let stepmsg = i18n("using " + stepcnt + " steps ");
        if (game.hintStatus & game.hintStatusAutoSolved) {
            finishColor = Kirigami.Theme.alternateBackgroundColor;
            finishHeader = i18n("There is your solution.")
            finishText = i18n("You gave in after " + stepcnt + " steps");
            finishMsg = "Automatically solved. ";
            finishMsg += i18n("Hints: ") + game.hintCount;
        } else if (game.hintCount || game.hintStatus & game.hintStatusUsedAutoPM) {
            finishColor = Kirigami.Theme.neutralBackgroundColor;
            finishHeader = i18n("Well done!");
            finishText = i18n("You finished this " + game.levelName + " suduko (with a bit of help) " + stepmsg + "in ");
            if (game.hintStatus & game.hintStatusUsedAutoPM) {
                finishMsg = i18n("Auto pencilmarks used. ")
            }
            finishMsg += i18n("Hints: ") + game.hintCount;
        } else {
            finishColor = Kirigami.Theme.positiveBackgroundColor;
            finishHeader = i18n("CONGRATULATIONS!!");
            finishText = i18n("You finished this " + game.levelName + " suduko with no hints or help " + stepmsg + "in ");
            finishMsg = i18n("Well done!")
        }

        // save statistics data - time, level
        // play a sound?
        drawer.open();
    }

    // UI

    Timer {
        id: timer
        running: applicationWindow().active && gamePage.isCurrentPage && !game.finished
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
        function reset() {
            elapsed = 0;
            stime = "00:00:00";
        }
    }

    // Game board
    Rectangle {
        id: boardContainer
        width: wideScreen ? Math.min(gameBoard.height, 600) : Math.min(gameBoard.width, 600)
        height: width
        x: isWideScreen ?  Math.max((parent.width - width*2)/2, 0) : (parent.width - width)/2
        y: isWideScreen ? Math.max((parent.height - height)/2, 0)
            : parent.width <= 600 ? 0 : (root.height - (height +  bottomTitle.height + bottomBar.height + buttonBoard.height))/2.5
        color: Kirigami.Theme.backgroundColor
        Rectangle {
            id: bgbd
            anchors.centerIn: parent
            property real pw: Math.floor((Math.min(parent.width, gameBoard.height)-12)/9)*9+12
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
                                    property int bmidx: game.boardMap[index + parent.index*9]
                                    property int rowIndex: bmidx > 0 ? bmidx/9 : 0
                                    property int columnIndex: index%3 + (parent.index%3)*3
                                    property int pencilMark: 0
                                    implicitHeight: width
                                    // color for various highlights: selected cell or digit.
                                        // logical errors
                                    color: (Config.logical_error_value && (game.errors[bmidx] & game.errValueLogical) === game.errValueLogical) ||
                                           // (Config.logical_error_pencilmark && (errors[bmidx] & errPencilMarkLogical) === errPencilMarkLogical)  ?
                                           (Config.logical_error_pencilmark && game.errors[bmidx] > 0 && game.errors[bmidx] < game.errPencilMarkLogical)  ?
                                        Kirigami.Theme.negativeBackgroundColor :
                                        // value errors
                                        (Config.error_value && (game.errors[bmidx] & game.errValue) === game.errValue) ? Kirigami.Theme.visitedLinkBackgroundColor :
                                        // erasable cells while erase button is checked
                                        btnErase.checked && Config.erasable && game.board[bmidx] == 0 && (game.values[bmidx] > 0 || game.pencilMarks[bmidx] > 0) ?
                                        Kirigami.Theme.neutralBackgroundColor :
                                        // values with number key active
                                        (Config.digit_value && game.values[bmidx] > 0 && game.values[bmidx] == game.currentDigit) || bmidx == game.currentCell ?
                                        Kirigami.Theme.highlightColor :
                                        // highlight pencilmarks with number key active
                                        Config.digit_pencilmark && game.values[bmidx] == 0 && (game.pencilMarks[bmidx] & (2**(game.currentDigit-1))) === 2**(game.currentDigit-1) ?
                                        Kirigami.Theme.positiveBackgroundColor :
                                        // highlight houses related to selected cell
                                        Config.houses && (rowIndex == game.currentRow || columnIndex == game.currentColumn || parent.index == game.currentBlock) ?
                                        Kirigami.Theme.activeBackgroundColor :
                                        Config.alternateBlockBackgrounds && parent.index%2 == 0 ? Kirigami.Theme.backgroundColor : Kirigami.Theme.alternateBackgroundColor
                                    Text {
                                        text: game.values[bmidx] > 0 ? game.values[bmidx] : ""
                                        anchors.centerIn: parent
                                        color: Kirigami.Theme.textColor
                                        font.pixelSize: parent.width*0.8
                                        font.bold: game.values[bmidx] == game.board[parent.bmidx]
                                    }
                                    TapHandler { onTapped: cellTapped(rowIndex, columnIndex, parent.parent.index, bmidx); }
                                    // pencil marks
                                    Rectangle {
                                        anchors.fill: parent
                                        visible: 0 == game.values[parent.bmidx]
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
                                                    opacity: (game.pencilMarks[parent.parent.parent.bmidx] & mark) === mark ? 1 : 0
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
        width: wideScreen ? Math.min(applicationWindow().width - boardContainer.x - boardContainer.width, boardContainer.width) : boardContainer.width
        height: wideScreen ? boardContainer.height : gamePage.height - boardContainer.height
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
                width: parent.sW*game.givenCount
                color: Kirigami.Theme.positiveBackgroundColor.darker(1.2)
            }
            Rectangle {
                id: progressSolved
                height: parent.height
                anchors.left: progressGivens.right
                width: parent.sW*(game.valueCnt - game.givenCount)
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
                    onClicked: game.undo();
                    enabled: game.undoPos > -1;
                }
                QQC2.Button {
                    Layout.fillWidth: true
                    id: btnRedo
                    text: i18n("Redo")
                    // text: "Gendan"
                    icon.name: "edit-redo-symbolic"
                    onClicked: game.redo();
                    enabled: game.undoPos < game.undoStack.length-1
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
                            onTriggered: game.solveCell(game.currentCell)
                            enabled: game.currentCell > -1 && game.board[game.currentCell] === 0
                        }
                        QQC2.MenuItem {
                            text: i18n("Set pencilmarks")
                            onTriggered: game.generatePencilMarks()
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
                        progress: (game.digitCounters[value])/9
                        checkable: false
                        checked: game.currentDigit == value
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
                            onTriggered: { resetPrompt.open() }
                            Kirigami.PromptDialog {
                                id: resetPrompt
                                title: i18n("Reset game?")
                                subtitle: i18n("You loose any changes you have made, reset can't be undone.")
                                standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
                                onAccepted: {
                                    game.reset();
                                    timer.reset();
                                }
                            }
                        }
                        QQC2.MenuItem {
                            text: i18n("Clear pencilmarks")
                            onTriggered: game.clearPencilMarks()
                        }
                        QQC2.MenuItem {
                            text: i18n("Give up")
                            onTriggered: { giveupPrompt.open() }
                            Kirigami.PromptDialog {
                                id: giveupPrompt
                                title: i18n("Give up?")
                                subtitle: i18n("Giving up means that you loose any changes you have made, it can't be undone.")
                                standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
                                onAccepted: {
                                    game.clear();
                                    gameBoard.goHome();
                                }
                            }
                        }
                        QQC2.MenuItem {
                            text: i18n("Solve game")
                            onTriggered: { solvePrompt.open() }
                            Kirigami.PromptDialog {
                                id: solvePrompt
                                title: i18n("Are you sure??")
                                subtitle: i18n("you loose any changes you have made, and can't solve the puzzele on your own!")
                                standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
                                onAccepted: {
                                    game.solve();
                                    finish();
                                }
                            }
                        }
                    }

                }
            }
        }
        Rectangle {
            id: bottomBar
            anchors.top: buttonBoard.bottom
            width: bottomContainer.width
            height: childrenRect.height
            color: Kirigami.Theme.backgroundColor
            QQC2.Label {
                Layout.alignment: Qt.AlignHCenter
                padding: Kirigami.Units.largeSpacing
                id: timerDisplay
                text: "Time: " + timer.stime
            }
        }

        // display for hints, finish info/congrats
        Rectangle {
            id: drawer
            width: parent.width
            // workaround for qml Layout preventing height property to be reliable.
            height: Math.max(implicitHeight, wideScreen ? boardContainer.height - bottomTitle.height : applicationWindow().height - bottomContainer.y)
            z: 1
            property bool isOpen: false
            states: [
                State {
                    name: "open"; when: drawer.isOpen
                    // PropertyChanges { target: drawer; y: bottomTitle.visible ? bottomTitle.height + 1 : 0; }
                    PropertyChanges { target: drawer; y: wideScreen ? bottomTitle.height + 1 : 0 }
                },
                State {
                    name: "closed"; when: !drawer.isOpen
                    PropertyChanges { target: drawer; y: applicationWindow().height }
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
                    text: finishText                }
                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    font.pointSize: 20
                    text:  timer.stime
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
                        text: i18n("Another " + game.levelName)
                        onClicked: { generateSudoku(game.level, 0); drawer.close(); }
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

