class Photo {
  final String id;
  final String author;
  final int width;
  final int height;
  final String url;
  final String downloadUrl;

  const Photo({
    required this.id,
    required this.author,
    required this.width,
    required this.height,
    required this.url,
    required this.downloadUrl,
  });

  /// Optimized medium-size thumbnail for grid view
  String get thumbnailUrl => 'https://picsum.photos/id/$id/360/480';

  /// High-resolution version for detail screen
  String get detailUrl => 'https://picsum.photos/id/$id/1200/900';

  /// Natural aspect ratio clamped between 0.65 and 1.25 for masonry layout
  double get masonryAspectRatio {
    if (width > 0 && height > 0) {
      final ratio = width / height;
      return ratio.clamp(0.65, 1.25);
    }
    final seed = int.tryParse(id) ?? id.hashCode;
    const ratios = [0.7, 0.85, 1.0, 0.75, 0.65];
    return ratios[seed.abs() % ratios.length];
  }

  /// Assigned category based on deterministic tag mapping
  String get category {
    const categories = ['Nature', 'Architecture', 'Travel', 'Portraits', 'Minimal', 'Tech'];
    final seed = int.tryParse(id) ?? id.hashCode;
    return categories[seed.abs() % categories.length];
  }


  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'].toString(),
      author: json['author'] as String? ?? 'Unknown Artist',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      downloadUrl: json['download_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'width': width,
      'height': height,
      'url': url,
      'download_url': downloadUrl,
    };
  }
}
