class GalleryImageModel {
  const GalleryImageModel({
    required this.id,
    this.imageUrl,
    this.thumbnailUrl,
    this.caption,
  });

  final String id;
  final String? imageUrl;
  final String? thumbnailUrl;

  final String? caption;
  String? get gridUrl => thumbnailUrl ?? imageUrl;

  String get fullCacheKey => 'gallery-image-$id';

  String get gridCacheKey =>
      thumbnailUrl == null ? fullCacheKey : 'gallery-thumb-$id';

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    return GalleryImageModel(
      id: (json['id'] ?? '').toString(),
      imageUrl: _optional(json['image_url'] ?? json['url']),
      thumbnailUrl: _optional(json['thumbnail_url'] ?? json['thumbnail']),
      caption: _optional(json['caption'] ?? json['title']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'image_url': imageUrl,
    'thumbnail_url': thumbnailUrl,
    'caption': caption,
  };

  static String? _optional(Object? value) {
    final String text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }
}
