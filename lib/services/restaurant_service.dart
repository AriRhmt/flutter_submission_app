import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/restaurant.dart';

class RestaurantService {
  const RestaurantService();

  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final jsonStr = await rootBundle.loadString('assets/data/restaurants.json');
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (jsonMap['restaurants'] as List).cast<Map<String, dynamic>>();
      return list.map((m) => Restaurant.fromMap(m)).toList();
    } catch (e) {
      rethrow;
    }
  }
}