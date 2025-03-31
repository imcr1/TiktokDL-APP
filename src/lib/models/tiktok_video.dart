class TikTokVideo {
  final String downloadPath;
  final String description;
  final String coverUrl;
  final String originalUrl;
  final DateTime timestamp;

  TikTokVideo({
    required this.downloadPath,
    required this.description,
    required this.coverUrl,
    required this.originalUrl,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'downloadPath': downloadPath,
      'description': description,
      'coverUrl': coverUrl,
      'originalUrl': originalUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TikTokVideo.fromJson(Map<String, dynamic> json) {
    return TikTokVideo(
      downloadPath: json['downloadPath'],
      description: json['description'],
      coverUrl: json['coverUrl'],
      originalUrl: json['originalUrl'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
