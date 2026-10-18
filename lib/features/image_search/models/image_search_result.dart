/// Model representing an image result from search or curated libraries.
class ImageSearchResult {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String fullUrl;
  final String source; // 'Openverse', 'Wikimedia', 'Unsplash', 'Curated'
  final String category; // 'Festival', 'Election', 'Background', 'Sticker', etc.
  final bool isTransparentSticker;
  final int? width;
  final int? height;

  const ImageSearchResult({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.fullUrl,
    this.source = 'Curated',
    this.category = 'General',
    this.isTransparentSticker = false,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'fullUrl': fullUrl,
      'source': source,
      'category': category,
      'isTransparentSticker': isTransparentSticker,
      'width': width,
      'height': height,
    };
  }

  factory ImageSearchResult.fromJson(Map<String, dynamic> json) {
    return ImageSearchResult(
      id: json['id'] as String? ?? 'img_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Poster Image',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      fullUrl: json['fullUrl'] as String? ?? '',
      source: json['source'] as String? ?? 'Curated',
      category: json['category'] as String? ?? 'General',
      isTransparentSticker: json['isTransparentSticker'] as bool? ?? false,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }
}
