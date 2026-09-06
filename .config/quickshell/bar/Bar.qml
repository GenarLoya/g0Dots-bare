import Quickshell
import QtQuick

PanelWindow {
  id: root
  color: "transparent"

  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 35

  CenterPill {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
  }

  RightPill {
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.verticalCenter: parent.verticalCenter
  }
}
