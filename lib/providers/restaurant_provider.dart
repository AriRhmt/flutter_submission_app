import 'package:flutter/foundation.dart';
import '../states/api_state.dart';
import '../models/restaurant_summary.dart';
import '../services/restaurant_api_service.dart';

class RestaurantProvider extends ChangeNotifier {
  RestaurantProvider({RestaurantApiService? api}) : _api = api ?? RestaurantApiService();

  final RestaurantApiService _api;

  ApiState<List<RestaurantSummary>> _state = const ApiLoading();
  ApiState<List<RestaurantSummary>> get state => _state;

  String _query = '';
  String get query => _query;

  Future<void> load() async {
    _state = const ApiLoading();
    notifyListeners();
    try {
      final data = await _api.fetchList();
      _state = ApiData<List<RestaurantSummary>>(data);
    } catch (e) {
      _state = ApiError<List<RestaurantSummary>>(e.toString());
    }
    notifyListeners();
  }

  Future<void> search(String q) async {
    _query = q;
    if (q.trim().isEmpty) {
      await load();
      return;
    }
    _state = const ApiLoading();
    notifyListeners();
    try {
      final data = await _api.search(q.trim());
      _state = ApiData<List<RestaurantSummary>>(data);
    } catch (e) {
      _state = ApiError<List<RestaurantSummary>>(e.toString());
    }
    notifyListeners();
  }
}