class RestaurantDetail {
  RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.pictureId,
    required this.rating,
    required this.menus,
    required this.customerReviews,
  });

  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String pictureId;
  final double rating;
  final Menus menus;
  final List<CustomerReview> customerReviews;

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    final r = json['restaurant'] as Map<String, dynamic>;
    return RestaurantDetail(
      id: r['id'] as String,
      name: r['name'] as String,
      description: r['description'] as String,
      city: r['city'] as String,
      address: r['address'] as String,
      pictureId: r['pictureId'] as String,
      rating: (r['rating'] as num).toDouble(),
      menus: Menus.fromJson(r['menus'] as Map<String, dynamic>),
      customerReviews: (r['customerReviews'] as List)
          .map((e) => CustomerReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Menus {
  Menus({required this.foods, required this.drinks});
  final List<MenuItem> foods;
  final List<MenuItem> drinks;

  factory Menus.fromJson(Map<String, dynamic> json) {
    final List foods = json['foods'] as List;
    final List drinks = json['drinks'] as List;
    return Menus(
      foods: foods.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList(),
      drinks: drinks.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class MenuItem {
  MenuItem({required this.name});
  final String name;

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(name: json['name'] as String);
}

class CustomerReview {
  CustomerReview({required this.name, required this.review, required this.date});
  final String name;
  final String review;
  final String date;

  factory CustomerReview.fromJson(Map<String, dynamic> json) => CustomerReview(
        name: json['name'] as String,
        review: json['review'] as String,
        date: json['date'] as String,
      );
}