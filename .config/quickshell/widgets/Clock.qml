import Quickshell
import QtQuick
import QtQuick.Layouts
import "../config.js" as Config

Row {
  spacing: 8

  // Fecha
  Text {
    color: Config.colors.fg
    font.family: Config.bar.fontFamily
    font.pixelSize: 13

    SystemClock {
      id: dateClock
      precision: SystemClock.Seconds
    }

    text: Qt.formatDateTime(dateClock.date, "ddd d MMM")
  }

  // Separador
  Rectangle {
    width: 1
    height: 14
    color: Config.colors.muted
    anchors.verticalCenter: parent.verticalCenter
  }

  // Hora con segundos
  Text {
    color: Config.colors.fg
    font.family: Config.bar.fontFamily
    font.pixelSize: 13
    font.weight: Font.Medium

    SystemClock {
      id: timeClock
      precision: SystemClock.Seconds
    }

    text: Qt.formatDateTime(timeClock.date, "HH:mm:ss")
  }
}
