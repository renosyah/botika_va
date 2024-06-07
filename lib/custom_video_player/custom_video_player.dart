import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer {
  VideoPlayerController? controller;
  late Completer videoInitialized;
  late Completer videoCompleted;

  bool initialize = false;

  bool isFinish = false;
  bool hasError = false;
  String errorMessage = "";

  double aspectRatio;
  Stream<bool>? interupt;
  Map<String, String> downloadHeader;

  StreamSubscription<bool>? interuptedListener;
  bool isInterupted = false;

  CustomVideoPlayer({
    required this.downloadHeader,
    required this.aspectRatio,
    this.interupt,
  }) {
    videoInitialized = Completer();
    videoCompleted = Completer();

    if (interupt != null) {
      interuptedListener = interupt!.listen(_onInterupted);
    }
  }

  void _onInterupted(bool stop) async {
    if (!stop || isInterupted) {
      return;
    }

    if (controller != null) {
      isInterupted = true;
      isFinish = true;
      await controller!.pause();

      if (!videoCompleted.isCompleted) {
        videoCompleted.complete();
      }
    }
  }

  Future<void> playFromFile(File? f) async {
    hasError = (f == null);

    try {
      controller = VideoPlayerController.file(
        f!,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );
      await controller!.initialize();
    } catch (_) {
      errorMessage = "Failed to play, invalid video file!";
      hasError = true;
      dispose();
    }

    videoInitialized.complete();
  }

  Future<void> playFromNetwork(
    Uri uri,
  ) async {
    VideoPlayerOptions options = VideoPlayerOptions(
      mixWithOthers: true,
    );

    try {
      controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: options,
        httpHeaders: downloadHeader,
      );
      await controller!.initialize();
    } catch (e) {
      errorMessage = "Failed to play, invalid video url!";
      hasError = true;
      dispose();
    }

    videoInitialized.complete();
  }

  Future<void> playFromAsset(String asset) async {
    hasError = false;

    try {
      controller = VideoPlayerController.asset(
        asset,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );
      await controller!.initialize();
    } catch (_) {
      hasError = true;
      dispose();
    }

    videoInitialized.complete();
  }

  Future<void> onPlay() async {
    if (isFinish || hasError) {
      return;
    }

    await videoInitialized.future;

    if (controller == null) {
      return;
    }

    controller!.addListener(_listen);
    await controller!.play();

    initialize = !hasError;

    await videoCompleted.future;
  }

  void _listen() {
    if (isFinish) {
      return;
    }

    if (controller!.value.hasError) {
      isFinish = true;
      videoCompleted.complete();
      return;
    }

    int dur = controller!.value.duration.inMilliseconds;
    int pos = controller!.value.position.inMilliseconds;
    if (dur - pos < 1) {
      isFinish = true;
      controller!.pause();
      videoCompleted.complete();
    }
  }

  Future<void> onPlayLoop() async {
    if (isFinish || hasError) {
      return;
    }

    await videoInitialized.future;

    if (controller == null) {
      return;
    }

    controller!.setLooping(true);
    await controller!.play();

    initialize = !hasError;
  }

  void dispose() async {
    if (isFinish) {
      return;
    }

    if (controller != null) {
      controller!.dispose();
    }

    isFinish = true;

    if (interuptedListener != null) {
      await interuptedListener!.cancel();
      interuptedListener = null;
    }
  }

  Widget build(BuildContext context) {
    return controller != null
        ? AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(controller!),
          )
        : const SizedBox.shrink();
  }
}
