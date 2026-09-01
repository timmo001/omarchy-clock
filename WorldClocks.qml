import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

Column {
  id: root

  required property QtObject bar
  required property color foreground
  required property string fontFamily

  property int minuteOffset: 0
  property bool minuteMode: false
  property double requestedEpoch: 0
  property double runningEpoch: 0
  property var clockRows: [
    { label: "Pacific", time: "--:--", zone: "---" },
    { label: "Mountain", time: "--:--", zone: "---" },
    { label: "Central", time: "--:--", zone: "---" },
    { label: "Eastern", time: "--:--", zone: "---" },
    { label: "Local", time: "--:--", zone: "---" }
  ]

  spacing: Style.space(10)

  function offsetLabel(value) {
    var offset = Math.round(value)
    if (offset === 0) return "NOW"
    if (minuteMode)
      return (offset > 0 ? "+" : "") + offset + (Math.abs(offset) === 1 ? " MINUTE" : " MINUTES")
    return (offset > 0 ? "+" : "") + offset + (Math.abs(offset) === 1 ? " HOUR" : " HOURS")
  }

  function reset() {
    minuteOffset = 0
  }

  function resetToNow() {
    reset()
    refresh(new Date())
  }

  function refresh(now) {
    requestedEpoch = Math.floor(now.getTime() / 1000) + minuteOffset * 60
    if (!timeProcess.running) runRequestedEpoch()
  }

  function runRequestedEpoch() {
    runningEpoch = requestedEpoch
    timeProcess.command = [
      "bash",
      "-c",
      "epoch=$1; for row in 'Pacific America/Los_Angeles' 'Mountain America/Denver' 'Central America/Chicago' 'Eastern America/New_York'; do "
        + "read -r label zone <<<\"$row\"; read -r time abbreviation <<<\"$(TZ=\"$zone\" date -d @\"$epoch\" '+%H:%M %Z')\"; "
        + "printf '%s\\t%s\\t%s\\n' \"$label\" \"$time\" \"$abbreviation\"; done; "
        + "read -r time abbreviation <<<\"$(date -d @\"$epoch\" '+%H:%M %Z')\"; printf 'Local\\t%s\\t%s\\n' \"$time\" \"$abbreviation\"",
      "timmo-clock",
      String(runningEpoch)
    ]
    timeProcess.running = true
  }

  function applyOutput(text) {
    var lines = String(text || "").trim().split("\n")
    if (lines.length !== 5) return

    var next = []
    for (var i = 0; i < lines.length; i++) {
      var fields = lines[i].split("\t")
      if (fields.length !== 3) return
      next.push({ label: fields[0], time: fields[1], zone: fields[2] })
    }
    clockRows = next
  }

  Process {
    id: timeProcess

    stdout: StdioCollector {
      id: timeOutput
      waitForEnd: true
    }

    onExited: function(exitCode) {
      if (exitCode === 0 && root.runningEpoch === root.requestedEpoch)
        root.applyOutput(timeOutput.text)
      if (root.runningEpoch !== root.requestedEpoch) root.runRequestedEpoch()
    }
  }

  Text {
    text: "WORLD CLOCKS"
    color: Qt.darker(root.foreground, 1.5)
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.letterSpacing: 1
    font.bold: true
  }

  Row {
    width: parent.width

    Repeater {
      model: root.clockRows

      Column {
        required property var modelData

        width: root.width / root.clockRows.length
        spacing: Style.space(2)

        Text {
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          text: parent.modelData.label.toUpperCase()
          color: Qt.darker(root.foreground, 1.5)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 0.5
        }

        Text {
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          text: parent.modelData.time
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.subtitle
          font.bold: true
        }

        Text {
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          text: parent.modelData.zone
          color: Qt.darker(root.foreground, 1.7)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }
      }
    }
  }

  Row {
    width: parent.width
    spacing: Style.space(12)

    Text {
      width: Style.space(72)
      anchors.verticalCenter: parent.verticalCenter
      text: root.minuteMode ? "-1440M" : "-24H"
      color: Qt.darker(root.foreground, 1.5)
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }

    PanelSlider {
      id: offsetSlider

      width: parent.width - Style.space(208)
      anchors.verticalCenter: parent.verticalCenter
      bar: root.bar
      value: root.minuteMode ? root.minuteOffset : root.minuteOffset / 60
      minimum: root.minuteMode ? -1440 : -24
      maximum: root.minuteMode ? 1440 : 24
      step: 1
      integer: true
      tickCount: 49

      onMoved: function(value) {
        root.minuteOffset = Math.round(value) * (root.minuteMode ? 1 : 60)
        root.refresh(new Date())
      }
      onReleased: function(value) {
        root.minuteOffset = Math.round(value) * (root.minuteMode ? 1 : 60)
        root.refresh(new Date())
      }
      onRightClicked: root.resetToNow()
    }

    Text {
      id: offsetLabel

      width: Style.space(112)
      anchors.verticalCenter: parent.verticalCenter
      horizontalAlignment: Text.AlignRight
      text: root.offsetLabel(offsetSlider.dragging
        ? offsetSlider.liveValue
        : (root.minuteMode ? root.minuteOffset : root.minuteOffset / 60))
      color: offsetLabelMouse.containsMouse
        ? Style.hoverStateColor(root.foreground, Color.accent)
        : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true

      MouseArea {
        id: offsetLabelMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.minuteMode = !root.minuteMode
      }

      PanelToolTip {
        visible: offsetLabelMouse.containsMouse
        text: root.minuteMode ? "Use hour increments" : "Use minute increments"
        fontFamily: root.fontFamily
      }
    }
  }
}
