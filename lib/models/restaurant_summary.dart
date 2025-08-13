class RestaurantSummary {
  RestaurantSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.pictureId,
  });

  final String id;
  final String name;
  final String city;
  final double rating;
  final String pictureId;

  factory RestaurantSummary.fromJson(Map<String, dynamic> json) {
    return RestaurantSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      rating: (json['rating'] as num).toDouble(),
      pictureId: json['pictureId'] as String,
    );
  }
}