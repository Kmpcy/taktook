// features/videos/repository/video_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:qemam_task/Core/Error/api_failures.dart';
import 'package:qemam_task/Core/api/api_services.dart';
import 'package:qemam_task/Features/Broadcast/Repo/video_repo.dart';
import 'package:qemam_task/Features/Broadcast/model/video_data_model.dart';

class VideoRepoImpl implements VideoRepo {
  final ApiService apiService;

  VideoRepoImpl(this.apiService);

  @override
  Future<Either<Failures, VideoResponse>> getVideos({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: "/popular",
        headers: {"Authorization": apiService.authKey},
      );

      final videoResponse = VideoResponse.fromJson(response);
      return Right(videoResponse);
    } catch (e) {
      return Left(ServerFailure("Failed to fetch videos: $e"));
    }
  }
}
