import 'video_model.dart';

class VideoResponse {
  final int page;
  final int perPage;
  final List<VideoModel> videos;

  VideoResponse({
    required this.page,
    required this.perPage,
    required this.videos,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) {
    return VideoResponse(
      page: json['page'],
      perPage: json['per_page'],
      videos: (json['videos'] as List)
          .map((e) => VideoModel.fromJson(e))
          .toList(),
    );
  }
}
