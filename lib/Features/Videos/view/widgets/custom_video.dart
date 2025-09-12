import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../model/video_model.dart';
import '../../view_model/videos_cubit/videos_cubit.dart';

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
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _showIcon = false;
  Timer? _iconTimer;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final controller = await widget.cubit.ensureController(widget.video);
    if (!mounted) return;
    _controller = controller;
    _initialized = controller.value.isInitialized;
    controller.setVolume(widget.isMuted ? 0 : 1);
    controller.addListener(() {
      if (mounted) setState(() {});
    });
    if (mounted) setState(() {});
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }

    setState(() => _showIcon = true);
    _iconTimer?.cancel();
    _iconTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showIcon = false);
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(() {});
    _iconTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_initialized) {
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
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),

          // ✅ أيقونة Play/Pause تظهر ثانية واحدة
          Center(
            child: AnimatedOpacity(
              opacity: _showIcon ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _controller!.value.isPlaying
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
