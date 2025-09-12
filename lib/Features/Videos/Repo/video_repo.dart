// features/videos/repository/video_repository.dart
import 'package:dartz/dartz.dart';
import 'package:qemam_task/Core/Error/api_failures.dart';
import 'package:qemam_task/Features/Videos/model/video_data_model.dart';
  abstract class VideoRepo {
  Future<Either<Failures, VideoResponse>> getVideos({
    int page,
    int perPage,
  });
}
