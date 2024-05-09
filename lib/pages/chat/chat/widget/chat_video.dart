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
  late StreamSubscription _msgProgressSubscription;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {}); // 视频初始化后刷新界面
      });

    // 监听消息发送进度的变化
    _msgProgressSubscription = widget.msgProgressControllerStream.listen((progress) {
      // 这里可以根据进度来更新UI，比如显示一个进度条
      // 注意检查setState是否在dispose之后调用，这可能导致错误
      if (mounted) {
        setState(() {
          // 更新进度相关UI
        });
      }
    });

    _controller.setLooping(true); // 根据需要设置循环播放
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放视频控制器资源
    _msgProgressSubscription.cancel(); // 取消进度监听
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: widget.videoWidth,
      height: widget.videoHeight,
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Center(child: CircularProgressIndicator()), // 加载时显示进度条
    );
  }
}
