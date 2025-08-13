import 'package:flutter/foundation.dart';
import '../states/api_state.dart';
import '../models/restaurant_detail.dart';
import '../services/restaurant_api_service.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  RestaurantDetailProvider({RestaurantApiService? api}) : _api = api ?? RestaurantApiService();

  final RestaurantApiService _api;

  ApiState<RestaurantDetail> _state = const ApiLoading();
  ApiState<RestaurantDetail> get state => _state;

  bool _submitting = false;
  bool get submitting => _submitting;

  String? _submitError;
  String? get submitError => _submitError;

  Future<void> load(String id) async {
    _state = const ApiLoading();
    notifyListeners();
    try {
      final detail = await _api.fetchDetail(id);
      _state = ApiData(detail);
    } catch (e) {
      _state = ApiError<RestaurantDetail>(e.toString());
    }
    notifyListeners();
  }

  Future<void> submitReview({required String id, required String name, required String review}) async {
    _submitting = true;
    _submitError = null;
    notifyListeners();
    try {
      final reviews = await _api.addReview(id: id, name: name, review: review);
      if (_state is ApiData<RestaurantDetail>) {
        final d = (_state as ApiData<RestaurantDetail>).value;
        final updated = RestaurantDetail(
          id: d.id,
          name: d.name,
          description: d.description,
          city: d.city,
          address: d.address,
          pictureId: d.pictureId,
          rating: d.rating,
          menus: d.menus,
          customerReviews: reviews,
        );
        _state = ApiData(updated);
      }
    } catch (e) {
      _submitError = e.toString();
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}