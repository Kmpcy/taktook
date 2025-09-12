class VideoModel {
  final int id;
  final int duration;
  final String thumbnail;
  final String videoUrl;

  VideoModel({
    required this.id,
    required this.duration,
    required this.thumbnail,
    required this.videoUrl,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final List videoFiles = json['video_files'] ?? [];

    String selectedUrl = videoFiles.isNotEmpty ? videoFiles.first['link'] : "";
    for (var file in videoFiles) {
      if (file['quality'] == 'hd') {
        selectedUrl = file['link'];
        break;
      }
    }

    String thumbnailUrl = json['image'];
    final List videoPictures = json['video_pictures'] ?? [];
    if (videoPictures.isNotEmpty) {
      thumbnailUrl = videoPictures.first['picture'];
    }

    return VideoModel(
      id: json['id'],
      duration: json['duration'],
      thumbnail: thumbnailUrl,
      videoUrl: selectedUrl,
    );
  }
}
