class PixabayImage {
  final int id;
  final String pageURL;
  final String type;
  final List<String> tags;
  final String previewURL;
  final int previewWidth;
  final int previewHeight;
  final String webformatURL;
  final int webformatWidth;
  final int webformatHeight;
  final String largeImageURL;
  final int imageWidth;
  final int imageHeight;
  final int imageSize;
  final int views;
  final int downloads;
  final int likes;
  final int comments;
  final int userId;
  final String user;
  final String userImageURL;

  const PixabayImage({
    required this.id,
    required this.pageURL,
    required this.type,
    required this.tags,
    required this.previewURL,
    required this.previewWidth,
    required this.previewHeight,
    required this.webformatURL,
    required this.webformatWidth,
    required this.webformatHeight,
    required this.largeImageURL,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageSize,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.comments,
    required this.userId,
    required this.user,
    required this.userImageURL,
  });

  /// Aspect ratio calculated from webformat width/height for responsive Masonry Grid
  double get aspectRatio {
    if (webformatWidth > 0 && webformatHeight > 0) {
      final ratio = webformatWidth / webformatHeight;
      // Clamp ratio to keep Masonry grid visually harmonious
      return ratio.clamp(0.65, 1.6);
    }
    return 1.0;
  }

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    // Parse tags from comma-separated string
    List<String> parsedTags = [];
    if (json['tags'] is String) {
      parsedTags = (json['tags'] as String)
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
    } else if (json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((t) => t.toString()).toList();
    }

    return PixabayImage(
      id: _parseInt(json['id']),
      pageURL: json['pageURL']?.toString() ?? '',
      type: json['type']?.toString() ?? 'photo',
      tags: parsedTags,
      previewURL: json['previewURL']?.toString() ?? '',
      previewWidth: _parseInt(json['previewWidth']),
      previewHeight: _parseInt(json['previewHeight']),
      webformatURL: json['webformatURL']?.toString() ?? '',
      webformatWidth: _parseInt(json['webformatWidth'], fallback: 640),
      webformatHeight: _parseInt(json['webformatHeight'], fallback: 480),
      largeImageURL: json['largeImageURL']?.toString() ?? json['webformatURL']?.toString() ?? '',
      imageWidth: _parseInt(json['imageWidth']),
      imageHeight: _parseInt(json['imageHeight']),
      imageSize: _parseInt(json['imageSize']),
      views: _parseInt(json['views']),
      downloads: _parseInt(json['downloads']),
      likes: _parseInt(json['likes']),
      comments: _parseInt(json['comments']),
      userId: _parseInt(json['user_id']),
      user: json['user']?.toString() ?? 'Unknown Photographer',
      userImageURL: json['userImageURL']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageURL': pageURL,
      'type': type,
      'tags': tags.join(', '),
      'previewURL': previewURL,
      'previewWidth': previewWidth,
      'previewHeight': previewHeight,
      'webformatURL': webformatURL,
      'webformatWidth': webformatWidth,
      'webformatHeight': webformatHeight,
      'largeImageURL': largeImageURL,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'imageSize': imageSize,
      'views': views,
      'downloads': downloads,
      'likes': likes,
      'comments': comments,
      'user_id': userId,
      'user': user,
      'userImageURL': userImageURL,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixabayImage && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
