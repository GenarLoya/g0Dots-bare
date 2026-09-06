import Quickshell
import QtQuick
import QtQuick.Layouts
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

    Workspaces {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 4
    }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 1
      height: 14
      color: Config.colors.muted
    }

    Clock {
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
