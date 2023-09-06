// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';

class MyVideoPlayer extends StatefulWidget {
  final File file;

  const MyVideoPlayer({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.file(widget.file)
      ..initialize().then((value) {
        controller.play();
        controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }
}
