import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.pumoku

Kirigami.Page {
    Rectangle {
        width: parent.width
        height: width
        border.width:1
        border.color: "black"
        color: "black"
        Grid {
            columns: 3
            spacing: 2
                Rectangle {
                    width: parent.width/3-4
                    height: width
                }
                Rectangle {
                    width: parent.width/3-4
                    height: width
                }
                Rectangle {
                    width: parent.width/3-4
                    height: width
                }
                Rectangle {
                    width: parent.width/3-4
                    height: width
                }
                Rectangle {
                    width: parent.width/3-4
                    height: width
                }
                Rectangle {
                    width: parent.width/3-4
                    height: width
                }
                Rectangle {
                    width: parent.width/3-4
                    height: width
                }
                Rectangle {
                    width: parent.width/3-4
                    height: width
                }
                Rectangle {
                    width: parent.width/3-4
                    height: width
                }

            // Repeater {
            //     model: 9
            //     Rectangle {
            //         required property int index
            //         width: parent.width/3-4
            //     }
            //     // Grid {
            //     //     columns: 3
            //     //     spacing: 1
            //     //     width: (parent.width/3) - 4
            //     //     height: width
            //     //     Repeater {
            //     //         model: 9
            //     //         Rectangle {
            //     //             width: parent.width/3 - 2
            //     //             height: width
            //     //             color: white
            //     //         }
            //     //     }
            //     // }
            // }
        }
    }
}
