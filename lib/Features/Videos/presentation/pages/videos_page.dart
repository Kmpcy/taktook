import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Features/Broadcast/model/video_model.dart';
import 'package:qemam_task/Features/Videos/presentation/widgets/custom_video.dart';
import 'package:qemam_task/Features/Videos/presentation/videos_cubit/videos_cubit.dart';
import 'package:qemam_task/Features/Videos/presentation/videos_cubit/videos_state.dart';
import 'package:video_player/video_player.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => VideosPageState();
}

class VideosPageState extends State<VideosPage> {
  late PageController pageController;
  VideosCubit? cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cubit ??= context.read<VideosCubit>();
    pageController = PageController(initialPage: cubit!.currentIndex);

    final st = cubit!.state;
    if (st is! VideosLoaded && st is! VideosLoading) {
      cubit!.loadVideos(loadNextPage: false);
    }
  }

  void _checkLoadMore(int index) {
    final cubit = this.cubit!;
    final currentPageNumber = (index ~/ 10) + 1;

    if (index >= (currentPageNumber * 10 - 2) &&
        cubit.hasMorePages &&
        !cubit.isLoading) {
      if (currentPageNumber < cubit.maxPages) {
        cubit.loadVideos(loadNextPage: true);
      }
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosCubit, VideosState>(
      builder: (context, state) {
        if (state is VideosLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VideosLoaded) {
          final cubit = this.cubit!;
          final totalItems = state.videos.length;

          return Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                itemCount: totalItems,
                onPageChanged: (index) async {
                  await cubit.updateIndex(index);
                  _checkLoadMore(index);
                },
                itemBuilder: (context, index) {
                  final VideoModel video = state.videos[index];
                  final isActive = index == state.currentIndex;

                  return Scaffold(
                    backgroundColor: Colors.black,
                    body: SafeArea(
                      child: Stack(
                        children: [
                          VideoPlayerItem(
                            video: video,
                            isActive: isActive,
                            isMuted: state.isMuted,
                            cubit: cubit,
                            maxHeight: MediaQuery.of(context).size.height,
                          ),

                           Positioned(
                            right: 12,
                            bottom: 120,
                            child: IconButton(
                              onPressed: () => cubit.toggleMute(),
                              icon: Icon(
                                state.isMuted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

               Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: List.generate(6, (segIndex) {
                          final activeSeg = state.currentIndex ~/ 10;
                          double progress = 0.0;
                          final segStart = segIndex * 10;
                          final segEnd = segStart + 9;
                          final idx = state.currentIndex;
                          if (idx >= segStart && idx <= segEnd) {
                            progress = ((idx - segStart) + 1) / 10.0;
                          } else if (idx > segEnd) {
                            progress = 1.0;
                          }

                          return Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 6),

                    if (cubit.getControllerIfExists(
                            state.videos[state.currentIndex].id) !=
                        null)
                      VideoProgressIndicator(
                        cubit.getControllerIfExists(
                            state.videos[state.currentIndex].id)!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        } else if (state is VideosError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => this.cubit!.loadVideos(loadNextPage: false),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
