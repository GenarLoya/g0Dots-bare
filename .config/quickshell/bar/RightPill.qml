import QtQuick
import "../config.js" as Config
import qs.widgets

Rectangle {
  id: pill
  height: 28
  radius: height / 2
  color: Config.colors.bg

  implicitWidth: contentRow.implicitWidth + 20

  Row {
    id: contentRow
    anchors.centerIn: parent
    spacing: 8

    Session {}
  }
}
