import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  Future<void> toggleFavorite(Map<String, dynamic> restaurant) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? <String>[];
    final id = restaurant['id'] as String;
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await prefs.setStringList('favorite_ids', ids);
  }

  Future<bool> isFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? <String>[];
    return ids.contains(id);
  }

  Future<List<Map<String, dynamic>>> allFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? <String>[];
    return ids.map((id) => {'id': id}).toList();
  }
}