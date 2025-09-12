// features/videos/viewmodel/videos_state.dart
import 'package:qemam_task/Features/Videos/model/video_model.dart';

 
abstract class VideosState {}

class VideosInitial extends VideosState {}

class VideosLoading extends VideosState {}

class VideosLoaded extends VideosState {
  final List<VideoModel> videos;
  final int currentIndex;
  final bool isMuted;
  final bool hasReachedEnd;

  VideosLoaded({
    required this.videos,
    required this.currentIndex,
    required this.isMuted,
    required this.hasReachedEnd,
  });

  VideosLoaded copyWith({
    List<VideoModel>? videos,
    int? currentIndex,
    bool? isMuted,
    bool? hasReachedEnd,
  }) {
    return VideosLoaded(
      videos: videos ?? this.videos,
      currentIndex: currentIndex ?? this.currentIndex,
      isMuted: isMuted ?? this.isMuted,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

class VideosError extends VideosState {
  final String message;
  VideosError(this.message);
}
