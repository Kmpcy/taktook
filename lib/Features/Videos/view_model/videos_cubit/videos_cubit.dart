// features/videos/viewmodel/videos_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Core/Error/api_failures.dart';
import 'package:qemam_task/Features/Videos/Repo/video_repo.dart';
import 'package:qemam_task/Features/Videos/model/video_data_model.dart';
import 'package:qemam_task/Features/Videos/model/video_model.dart';
import 'package:video_player/video_player.dart';
import 'package:dartz/dartz.dart';

 
import 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  final VideoRepo repository;

  // pagination logic
  int currentPage = 1;
  final int perPage = 10;
  final int maxPages = 6; // per task
  bool isLoading = false;
  final Set<int> loadedPages = {}; // pages already loaded (prevent duplicate page loads)
  bool hasMorePages = true;

  // stateful info
  int currentIndex = 0;
  bool isMuted = false;

  // data + controllers
  List<VideoModel> videos = [];
  final Map<int, VideoPlayerController> controllers = {};

  VideosCubit(this.repository) : super(VideosInitial());

  /// Load first page or next page
  Future<void> loadVideos({bool loadNextPage = false}) async {
    if (isLoading) return;
    // decide page to load
    int pageToLoad = loadNextPage ? currentPage : 1;

    if (!loadNextPage) {
      // fresh load
      isLoading = true;
      emit(VideosLoading());
      videos.clear();
      // keep controllers? we clear controllers only on full fresh load to avoid stale controllers if you want:
      // We'll clear controllers to free memory on full refresh
      for (var c in controllers.values) {
        try { c.dispose(); } catch (_) {}
      }
      controllers.clear();
      loadedPages.clear();
      currentPage = 1;
      hasMorePages = true;
    } else {
      // guard: stop if no more pages or exceeded maxPages
      if (!hasMorePages || currentPage > maxPages || loadedPages.contains(currentPage)) {
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
        // append response.videos (ensure uniqueness if API might repeat)
        final newVideos = response.videos.where((v) => videos.any((e) => e.id == v.id) == false).toList();
        videos.addAll(newVideos);

        // mark page loaded
        loadedPages.add(pageToLoad);

        // update currentPage pointer for next load
        // if we loaded page 1 and want next, currentPage should be 2 next.
        if (pageToLoad >= currentPage) currentPage = pageToLoad + 1;

        // hasMorePages: stop at maxPages or if the returned list is empty
        if (videos.length >= maxPages * perPage || response.videos.isEmpty || pageToLoad >= maxPages) {
          hasMorePages = false;
        }

        isLoading = false;
        emit(VideosLoaded(
          videos: List.from(videos),
          currentIndex: currentIndex,
          isMuted: isMuted,
          hasReachedEnd: !hasMorePages,
        ));
      },
    );
  }

  /// get or create controller and ensure it's initialized and listeners attached
  Future<VideoPlayerController> ensureController(VideoModel video) async {
    if (controllers.containsKey(video.id)) {
      final existing = controllers[video.id]!;
      // if not initialized, try to initialize (rare)
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
      // no automatic play here; caller will handle based on isActive
      // when controller state changes we want UI to rebuild: emit current state
      controller.addListener(() {
        // emit simple state update so UI refreshes icon/progress
        if (state is VideosLoaded) {
          emit((state as VideosLoaded).copyWith()); // shallow emit to rebuild listeners
        }
      });
      return controller;
    }
  }

  /// returns controller if exists (synchronous). Use ensureController for guaranteed init.
  VideoPlayerController? getControllerIfExists(int videoId) {
    return controllers[videoId];
  }

  /// Dispose controllers that are far from current index (keep current + adjacent)
 void disposeFarControllers(int index) {
  if (videos.isEmpty) return;

  // خلي معاك الفيديو الحالي + واحد قبل + واحد بعد
  final keepIds = <int>{};
  keepIds.add(videos[index].id);
  if (index - 1 >= 0) keepIds.add(videos[index - 1].id);
  if (index + 1 < videos.length) keepIds.add(videos[index + 1].id);

  final toDispose = controllers.keys.where((id) => !keepIds.contains(id)).toList();

  for (var id in toDispose) {
    try {
      controllers[id]?.dispose();
    } catch (_) {}
    controllers.remove(id);
  }
}


  /// called from UI when page changes
  Future<void> updateIndex(int index) async {
  currentIndex = index;

  if (index < 0 || index >= videos.length) return;

  // Pre-initialize current + neighbors
  await ensureController(videos[index]);
  if (index + 1 < videos.length) ensureController(videos[index + 1]);
  if (index - 1 >= 0) ensureController(videos[index - 1]);

  // ✅ هنا بيتم التخلص من أي controllers بعيدة
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
    // apply to existing controllers
    controllers.values.forEach((c) {
      try { c.setVolume(isMuted ? 0 : 1); } catch (_) {}
    });
  }

  /// Play/Pause control for a video (keeps position)
  void togglePlayPause(VideoModel video) {
    final controller = controllers[video.id];
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      // emit to update icons
      if (state is VideosLoaded) emit((state as VideosLoaded).copyWith());
    }
  }

  /// call on overall dispose (like when leaving feature)
  void disposeAll() {
    for (var c in controllers.values) {
      try { c.dispose(); } catch (_) {}
    }
    controllers.clear();
  }
}
