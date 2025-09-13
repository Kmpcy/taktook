import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Core/Error/api_failures.dart';
import 'package:qemam_task/Features/data/Repo/video_repo.dart';
import 'package:qemam_task/Features/Broadcast/model/video_data_model.dart';
import 'package:qemam_task/Features/Broadcast/model/video_model.dart';
import 'package:video_player/video_player.dart';
import 'package:dartz/dartz.dart';

import 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  final VideoRepo repository;

  int currentPage = 1;
  final int perPage = 10;
  final int maxPages = 6;
  bool isLoading = false;
  final Set<int> loadedPages = {};
  bool hasMorePages = true;

  int currentIndex = 0;
  bool isMuted = false;

  List<VideoModel> videos = [];
  final Map<int, VideoPlayerController> controllers = {};

  VideosCubit(this.repository) : super(VideosInitial());

  Future<void> loadVideos({bool loadNextPage = false}) async {
    if (isLoading) return;
    int pageToLoad = loadNextPage ? currentPage : 1;

    if (!loadNextPage) {
      // fresh load
      isLoading = true;
      emit(VideosLoading());
      videos.clear();

      for (var c in controllers.values) {
        try {
          c.dispose();
        } catch (_) {}
      }
      controllers.clear();
      loadedPages.clear();
      currentPage = 1;
      hasMorePages = true;
    } else {
      if (!hasMorePages ||
          currentPage > maxPages ||
          loadedPages.contains(currentPage)) {
        return;
      }
    }

    isLoading = true;

    final Either<Failures, VideoResponse> result = await repository.getVideos(
      page: pageToLoad,
      perPage: perPage,
    );

    result.fold(
      (failure) {
        isLoading = false;
        emit(VideosError(failure.errorMessage));
      },
      (response) {
        final newVideos = response.videos
            .where((v) => videos.any((e) => e.id == v.id) == false)
            .toList();
        videos.addAll(newVideos);

        loadedPages.add(pageToLoad);

        if (pageToLoad >= currentPage) currentPage = pageToLoad + 1;

        if (videos.length >= maxPages * perPage ||
            response.videos.isEmpty ||
            pageToLoad >= maxPages) {
          hasMorePages = false;
        }

        isLoading = false;
        emit(
          VideosLoaded(
            videos: List.from(videos),
            currentIndex: currentIndex,
            isMuted: isMuted,
            hasReachedEnd: !hasMorePages,
          ),
        );
      },
    );
  }

  Future<VideoPlayerController> ensureController(VideoModel video) async {
    if (controllers.containsKey(video.id)) {
      final existing = controllers[video.id]!;
      if (!existing.value.isInitialized) {
        try {
          await existing.initialize();
        } catch (_) {}
      }
      return existing;
    } else {
      final controller = VideoPlayerController.network(video.videoUrl);
      controllers[video.id] = controller;
      try {
        await controller.initialize();
      } catch (_) {}
      controller.addListener(() {
        if (state is VideosLoaded) {
          emit((state as VideosLoaded).copyWith());
        }
      });
      return controller;
    }
  }

  VideoPlayerController? getControllerIfExists(int videoId) {
    return controllers[videoId];
  }

  void disposeFarControllers(int index) {
    if (videos.isEmpty) return;

    final keepIds = <int>{};
    keepIds.add(videos[index].id);
    if (index - 1 >= 0) keepIds.add(videos[index - 1].id);
    if (index + 1 < videos.length) keepIds.add(videos[index + 1].id);

    final toDispose = controllers.keys
        .where((id) => !keepIds.contains(id))
        .toList();

    for (var id in toDispose) {
      try {
        controllers[id]?.dispose();
      } catch (_) {}
      controllers.remove(id);
    }
  }

  Future<void> updateIndex(int index) async {
    currentIndex = index;

    if (index < 0 || index >= videos.length) return;

    await ensureController(videos[index]);
    if (index + 1 < videos.length) ensureController(videos[index + 1]);
    if (index - 1 >= 0) ensureController(videos[index - 1]);

    disposeFarControllers(index);

    if (state is VideosLoaded) {
      emit((state as VideosLoaded).copyWith(currentIndex: index));
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (state is VideosLoaded) {
      emit((state as VideosLoaded).copyWith(isMuted: isMuted));
    }
    controllers.values.forEach((c) {
      try {
        c.setVolume(isMuted ? 0 : 1);
      } catch (_) {}
    });
  }

  void togglePlayPause(VideoModel video) {
    final controller = controllers[video.id];
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      if (state is VideosLoaded) emit((state as VideosLoaded).copyWith());
    }
  }

  void disposeAll() {
    for (var c in controllers.values) {
      try {
        c.dispose();
      } catch (_) {}
    }
    controllers.clear();
  }
}
