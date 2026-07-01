# lib/models/ad_model.dart

// نموذج بيانات للإعلانات
// المصدر: نقل من الجذر

class AdModel {
  final int id;
  final String title;
  final String imageUrl;
  final String link;

  AdModel({required this.id, required this.title, required this.imageUrl, required this.link});

  factory AdModel.fromJson(Map<String, dynamic> json) => AdModel(
    id: int.parse(json['id']?.toString() ?? '0'),
    title: json['title'] ?? '',
    imageUrl: json['image'] ?? '',
    link: json['link'] ?? '',
  );
}
