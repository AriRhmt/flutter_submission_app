import 'package:flutter/foundation.dart';

import '../../data/models/example_model.dart';
import '../../data/services/api_service.dart';

class ExampleProvider extends ChangeNotifier {
  ExampleProvider({ApiService? apiService}) : _api = apiService ?? const ApiService();

  final ApiService _api;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<HealthItem> _items = const [];
  List<HealthItem> get items => _items;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _api.fetchHealthItems();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  HealthItem? getById(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}