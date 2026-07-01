class AdModel {
  final String id;
  final String title;
  final String image;
  final String link;
  final String type;

  AdModel({
    required this.id,
    required this.title,
    required this.image,
    required this.link,
    required this.type,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['ad_id'].toString(),
      title: json['ad_title'],
      image: json['ad_image'],
      link: json['ad_link'] ?? "",
      type: json['ad_type'],
    );
  }
}
