import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../services/favorite_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/search_bar_widget.dart';

class MainListPage extends StatefulWidget {
  const MainListPage({super.key});

  @override
  State<MainListPage> createState() => _MainListPageState();
}

class _MainListPageState extends State<MainListPage> {
  final _service = const RestaurantService();
  final _favoriteService = FavoriteService();
  List<Restaurant> _items = const [];
  Set<String> _favorites = {};
  String _query = '';
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchRestaurants();
      final favRows = await _favoriteService.allFavorites();
      setState(() {
        _items = data;
        _favorites = favRows.map((e) => e['id'] as String).toSet();
      });
    } catch (e) {
      setState(() => _error = e);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleFavorite(Restaurant r) async {
    await _favoriteService.toggleFavorite({
      'id': r.id,
      'name': r.name,
      'city': r.city,
      'rating': r.rating,
      'description': r.description,
      'image': r.image,
    });
    final favRows = await _favoriteService.allFavorites();
    setState(() => _favorites = favRows.map((e) => e['id'] as String).toSet());
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items
        .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()) || e.city.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Restaurants'),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBarWidget(
                  hint: 'Search restaurants... ',
                  onChanged: (val) => setState(() => _query = val),
                ),
              ),
            ),
            if (_loading) ...[
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    childCount: 6,
                  ),
                ),
              ),
            ] else if (_error != null) ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Something went wrong. Please try again.'),
                      const SizedBox(height: 12),
                      CustomButton.secondary(onPressed: _load, label: 'Retry'),
                    ],
                  ),
                ),
              )
            ] else if (filtered.isEmpty) ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.search_off_rounded, size: 48),
                      SizedBox(height: 8),
                      Text('No restaurants found'),
                    ],
                  ),
                ),
              )
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    int columns = 1;
                    if (width >= 1200) columns = 4; else if (width >= 900) columns = 3; else if (width >= 600) columns = 2;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final r = filtered[index];
                          final isFav = _favorites.contains(r.id);
                          return _RestaurantCard(
                            restaurant: r,
                            isFavorite: isFav,
                            onFavorite: () => _toggleFavorite(r),
                            onTap: () => Navigator.of(context).pushNamed('/detail', arguments: r),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.restaurant,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'rest_${restaurant.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(imageUrl: restaurant.image, fit: BoxFit.cover, placeholder: (c,_)=>Container(color: Colors.black12), errorWidget: (c,_,__)=>(const Icon(Icons.broken_image_rounded))),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16),
                        const SizedBox(width: 4),
                        Flexible(child: Text(restaurant.city, style: Theme.of(context).textTheme.bodyMedium)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.pinkAccent),
                onPressed: onFavorite,
              )
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(restaurant.rating.toStringAsFixed(1)),
            ],
          )
        ],
      ),
    );
  }
}