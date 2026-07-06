class AdModel {
  final String id;
  final String? imageUrl;
  final String? title;
  final String? link;
  final int clicks;
  final bool isActive;

  AdModel({
    required this.id,
    this.imageUrl,
    this.title,
    this.link,
    this.clicks = 0,
    this.isActive = true,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id:       json['id']?.toString() ?? '',
      imageUrl: json['image_url'],
      title:    json['title'],
      link:     json['link'],
      clicks:   json['clicks'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}
