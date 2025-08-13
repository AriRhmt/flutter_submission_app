import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _prefsKey = 'favorite_ids';

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  Future<void> toggleFavorite(Map<String, dynamic> restaurant) async {
    final prefs = await _prefs();
    final String id = restaurant['id'] as String;
    final List<String> current = prefs.getStringList(_prefsKey) ?? <String>[];
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await prefs.setStringList(_prefsKey, current);
  }

  Future<bool> isFavorite(String id) async {
    final prefs = await _prefs();
    final List<String> current = prefs.getStringList(_prefsKey) ?? <String>[];
    return current.contains(id);
  }

  Future<List<Map<String, dynamic>>> allFavorites() async {
    final prefs = await _prefs();
    final List<String> current = prefs.getStringList(_prefsKey) ?? <String>[];
    // Return list of maps to be compatible with existing code that expects maps with 'id'
    return current.map((id) => {'id': id}).toList();
  }
}