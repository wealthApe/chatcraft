import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class ChatVideoView extends StatefulWidget {
  final String msgId;
  final Stream msgProgressControllerStream;
  final String videoUrl;
  final bool isFromMsg;
  final double videoWidth;
  final double videoHeight;

  const ChatVideoView({
    Key? key,
    required this.msgId,
    required this.msgProgressControllerStream,
    required this.videoUrl,
    required this.isFromMsg,
    required this.videoWidth,
    required this.videoHeight,
  }) : super(key: key);

  @override
  _ChatVideoViewState createState() => _ChatVideoViewState();
}

class _ChatVideoViewState extends State<ChatVideoView> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        widget.videoUrl,
      ),
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.setLooping(false); // 根据需要设置循环播放
    // 增加播放按钮 点击播放
    
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放视频控制器资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return Container(
      width: widget.videoWidth,
      height: widget.videoHeight,
      // 添加一个 底部容器，增加两个button
      child: Stack(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 如果视频初始化完成，显示视频
                return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                );
              } else {
                // 如果视频尚未初始化完成，显示一个加载中的图标
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            // 半透明背景
            child: Container(
              color: Colors.black.withOpacity(0.5),
              height: 40,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: () {
                    setState(() {
                      _controller.pause();
                      _controller.seekTo(Duration.zero);
                    });
                  },
                ),
              ],
            )
            ),
          ),
        ],
      ),
      

    );
  }
}
