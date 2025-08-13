import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant_summary.dart';
import '../models/restaurant_detail.dart';

class RestaurantApiService {
  static const String _base = 'https://restaurant-api.dicoding.dev';

  Future<List<RestaurantSummary>> fetchList() async {
    final uri = Uri.parse('$_base/list');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load restaurants (${res.statusCode})');
    }
    final Map<String, dynamic> map = json.decode(res.body) as Map<String, dynamic>;
    final List list = (map['restaurants'] as List);
    return list.map((e) => RestaurantSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<RestaurantSummary>> search(String query) async {
    final uri = Uri.parse('$_base/search?q=$query');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Search failed (${res.statusCode})');
    }
    final Map<String, dynamic> map = json.decode(res.body) as Map<String, dynamic>;
    final List list = (map['restaurants'] as List);
    return list.map((e) => RestaurantSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RestaurantDetail> fetchDetail(String id) async {
    final uri = Uri.parse('$_base/detail/$id');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load detail (${res.statusCode})');
    }
    final Map<String, dynamic> map = json.decode(res.body) as Map<String, dynamic>;
    return RestaurantDetail.fromJson(map);
  }

  Future<List<CustomerReview>> addReview({
    required String id,
    required String name,
    required String review,
  }) async {
    final uri = Uri.parse('$_base/review');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'name': name, 'review': review}),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to submit review (${res.statusCode})');
    }
    final Map<String, dynamic> map = json.decode(res.body) as Map<String, dynamic>;
    final List list = (map['customerReviews'] as List);
    return list.map((e) => CustomerReview.fromJson(e as Map<String, dynamic>)).toList();
  }

  String imageUrl(String pictureId, {String size = 'medium'}) => '$_base/images/$size/$pictureId';
}