import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../Broadcast/model/video_model.dart';
import '../videos_cubit/videos_cubit.dart';

class VideoPlayerItem extends StatefulWidget {
  final VideoModel video;
  final bool isActive;
  final bool isMuted;
  final VideosCubit cubit;
  final double maxHeight;

  const VideoPlayerItem({
    super.key,
    required this.video,
    required this.isActive,
    required this.isMuted,
    required this.cubit,
    this.maxHeight = double.infinity,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? controller;
  bool initialized = false;
  bool _showIcon = false;
  Timer? iconTimer;

  @override
  void initState() {
    super.initState();
    prepare();
  }

  Future<void> prepare() async {
    final controller = await widget.cubit.ensureController(widget.video);
    if (!mounted) return;
    this.controller = controller;
    initialized = controller.value.isInitialized;
    controller.setVolume(widget.isMuted ? 0 : 1);
    controller.addListener(() {
      if (mounted) setState(() {});
    });
    if (mounted) setState(() {});
  }

  void _togglePlayPause() {
    if (controller == null) return;

    if (controller!.value.isPlaying) {
      controller!.pause();
    } else {
      controller!.play();
    }

    setState(() => _showIcon = true);
    iconTimer?.cancel();
    iconTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showIcon = false);
    });
  }

  @override
  void dispose() {
    controller?.removeListener(() {});
    iconTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller!.value.size.width,
              height: controller!.value.size.height,
              child: VideoPlayer(controller!),
            ),
          ),

           Center(
            child: AnimatedOpacity(
              opacity: _showIcon ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                controller!.value.isPlaying
                    ? Icons.pause_circle
                    : Icons.play_circle,
                size: 84,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
