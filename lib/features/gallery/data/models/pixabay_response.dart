import 'pixabay_image.dart';

class PixabayResponse {
  final int total;
  final int totalHits;
  final List<PixabayImage> hits;

  const PixabayResponse({
    required this.total,
    required this.totalHits,
    required this.hits,
  });

  factory PixabayResponse.fromJson(Map<String, dynamic> json) {
    final hitsList = (json['hits'] as List<dynamic>?)
            ?.map((item) => PixabayImage.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return PixabayResponse(
      total: json['total'] is int ? json['total'] : int.tryParse('${json['total']}') ?? 0,
      totalHits: json['totalHits'] is int ? json['totalHits'] : int.tryParse('${json['totalHits']}') ?? 0,
      hits: hitsList,
    );
  }
}
