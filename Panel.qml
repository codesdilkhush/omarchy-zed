import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Panel {
  id: root
  moduleName: "codesdilkhush.zed"
  ipcTarget: "codesdilkhush.zed"
  manageIpc: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property bool vertical: root.bar ? root.bar.vertical : false
  readonly property color foreground: root.barForeground
  readonly property color urgentColor: root.bar ? root.bar.urgent : Commons.Color.urgent
  readonly property color accentColor: Commons.Color.accent
  readonly property string fontFamily: root.bar ? root.bar.fontFamily : Style.font.family

  property bool running: false
  property string themeName: ""
  property string zedTheme: ""
  property bool themeSynced: false

  ShellIpc {
    target: "codesdilkhush.zed"
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
    function launch(): void { root.focusOrLaunch() }
    function newWindow(): void { root.newWindow() }
    function syncTheme(): void { root.syncTheme() }
  }

  Commons.Translations {
    id: strings
    directory: Qt.resolvedUrl("i18n")
  }

  function parseStatus(raw) {
    try {
      var data = JSON.parse(raw)
      root.running = data.running === true
      root.themeName = data.theme_name || "Unknown"
      root.zedTheme = data.zed_theme || "Unknown"
      root.themeSynced = data.theme_synced === true
    } catch (e) {
      // ignore JSON parse error
    }
  }

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function focusOrLaunch() {
    root.close()
    if (root.running) {
      Quickshell.execDetached(["hyprctl", "dispatch", "focuswindow", "class:^(dev.zed.Zed)$"])
    } else {
      if (root.bar && typeof root.bar.run === "function") {
        root.bar.run("setsid uwsm-app -- gtk-launch dev.zed.Zed")
      } else {
        Quickshell.execDetached(["setsid", "uwsm-app", "--", "gtk-launch", "dev.zed.Zed"])
      }
    }
    refresh()
  }

  function newWindow() {
    root.close()
    Quickshell.execDetached(["zeditor", "--new"])
    refresh()
  }

  function syncTheme() {
    Quickshell.execDetached(["omazed", "sync"])
    refresh()
  }

  onOpenedChanged: {
    if (opened) refresh()
  }

  Process {
    id: statusProc
    command: [String(Qt.resolvedUrl("zed-status.sh")).replace(/^file:\/\//, "")]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseStatus(text)
    }
  }

  Timer {
    interval: root.opened ? 1500 : 3500
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf121"
    labelText: ""
    tooltipText: root.running 
      ? (strings.t("zed.tooltipRunning") + " [" + root.themeName + "]") 
      : strings.t("zed.tooltipStopped")
    active: root.opened || root.running
    activeColor: root.running ? root.accentColor : root.foreground
    onPressed: function(b) {
      if (b === Qt.RightButton) {
        root.toggle()
      } else if (b === Qt.MiddleButton) {
        root.newWindow()
      } else {
        root.focusOrLaunch()
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(320))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      implicitHeight: contentColumn.implicitHeight
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(12)

        // Hero header
        Row {
          width: parent.width
          spacing: Style.space(12)

          Text {
            textFormat: Text.PlainText
            text: "\uf121"
            color: root.accentColor
            font.family: root.fontFamily
            font.pixelSize: Style.font.display
            anchors.verticalCenter: parent.verticalCenter
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              textFormat: Text.PlainText
              text: strings.t("zed.title")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
            }

            Text {
              textFormat: Text.PlainText
              text: (root.running ? strings.t("zed.running") : strings.t("zed.stopped")) + 
                    " · " + (root.themeSynced ? strings.t("zed.synced") : strings.t("zed.notSynced")) +
                    (root.themeName ? (" (" + root.themeName + ")") : "")
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
            }
          }
        }

        PanelSeparator { foreground: root.foreground }

        // Primary Action Button (Focus or Launch)
        Button {
          width: parent.width
          text: root.running ? strings.t("zed.focus") : strings.t("zed.launch")
          iconText: root.running ? "\uf065" : "\uf04b"
          foreground: root.foreground
          fontFamily: root.fontFamily
          horizontalPadding: Style.spacing.controlPaddingX
          verticalPadding: Style.spacing.controlPaddingY
          bordered: true
          onClicked: root.focusOrLaunch()
        }

        // New Window Action
        Button {
          width: parent.width
          text: strings.t("zed.newWindow")
          iconText: "\uf067"
          foreground: root.foreground
          fontFamily: root.fontFamily
          horizontalPadding: Style.spacing.controlPaddingX
          verticalPadding: Style.spacing.controlPaddingY
          bordered: true
          onClicked: root.newWindow()
        }

        // Sync Theme Action
        Button {
          width: parent.width
          text: strings.t("zed.syncTheme")
          iconText: "\uf021"
          foreground: root.foreground
          fontFamily: root.fontFamily
          horizontalPadding: Style.spacing.controlPaddingX
          verticalPadding: Style.spacing.controlPaddingY
          bordered: true
          onClicked: root.syncTheme()
        }
      }
    }
  }
}
