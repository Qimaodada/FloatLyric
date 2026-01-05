import QtQuick
import QtQuick.Window
import QtMultimedia
import QtQuick.Dialogs
import QtQuick.Controls

Window {
    width: 900
    height: 600
    visible: true
    title: "FloatLyric PC Demo - 视频 + 浮动歌词"

    // 背景色，避免纯黑看不清
    color: "black"

    // 视频播放器（必须在 VideoOutput 之前声明）
    MediaPlayer {
        id: mediaPlayer
        autoPlay: true
        videoOutput: videoOutput  // Qt6 关键绑定

        // 同步歌词
        onPositionChanged: updateLyrics()
    }

    // 视频显示层
    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit

        // 歌词叠加层（AR-like 浮动效果）
        Item {
            id: lyricOverlay
            anchors.fill: parent

            Text {
                id: lyricText
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height / 2  // 初始垂直居中
                font.pixelSize: 56
                color: "white"
                style: Text.Outline
                styleColor: "black"
                text: "点击下方按钮导入视频"
                opacity: 0

                // 淡入动画
                NumberAnimation on opacity {
                    id: fadeAnim
                    from: 0; to: 1; duration: 600
                }

                // 上下浮动动画（模拟 AR 漂浮感）
                SequentialAnimation on y {
                    id: floatAnim
                    running: false
                    loops: Animation.Infinite
                    NumberAnimation { from: parent.height / 2 - 30; to: parent.height / 2 + 30; duration: 3000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: parent.height / 2 + 30; to: parent.height / 2 - 30; duration: 3000; easing.type: Easing.InOutSine }
                }
            }
        }

        // 导入视频按钮（放在视频上方）
        Button {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 40
            width: 220
            height: 60
            text: "导入本地视频"
            font.pixelSize: 24
            background: Rectangle { color: "#AA0078D7"; radius: 12 }

            onClicked: fileDialog.open()
        }
    }

    // 文件选择对话框
    FileDialog {
        id: fileDialog
        title: "请选择一个视频文件"
        //folder: shortcuts.videos  // 默认打开视频文件夹
        nameFilters: [ "Video files (*.mp4 *.avi *.mov *.mkv *.webm)" ]
        onAccepted: {
            // 修复第75行错误：fileUrl 是 QUrl 类型，直接赋值即可
            mediaPlayer.source = selectedFile
            mediaPlayer.play()

            // 重置歌词
            currentLyricIndex = 0
            lyricText.text = "加载中..."
            lyricText.opacity = 1
        }
    }

    // 模拟 LRC 歌词数据（时间单位：毫秒）
    property var lyrics: [
        { time: 0,     text: "欢迎使用 FloatLyric" },
        { time: 3000,  text: "这是第一句歌词" },
        { time: 7000,  text: "歌词会浮动出现~" },
        { time: 11000, text: "支持任意本地视频" },
        { time: 15000, text: "后期可加 BGM 和真实 LRC" },
        { time: 20000, text: "✨ 酷炫 AR 效果模拟中 ✨" }
    ]

    property int currentLyricIndex: -1

    // 更新当前歌词
    function updateLyrics() {
        if (currentLyricIndex >= lyrics.length - 1) return

        while (currentLyricIndex + 1 < lyrics.length &&
               mediaPlayer.position >= lyrics[currentLyricIndex + 1].time) {
            currentLyricIndex++
        }

        var newText = lyrics[currentLyricIndex].text
        if (lyricText.text !== newText) {
            lyricText.text = newText
            fadeAnim.restart()
            floatAnim.restart()
        }
    }

    // 初始提示
    Component.onCompleted: {
        lyricText.opacity = 1
    }
}
