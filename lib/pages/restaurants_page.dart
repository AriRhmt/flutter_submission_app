import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../states/api_state.dart';
import '../services/restaurant_api_service.dart';
import '../models/restaurant_summary.dart';
import '../widgets/debounced_search_field.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestaurantsPage extends StatelessWidget {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestaurantProvider(api: RestaurantApiService())..load(),
      child: Scaffold(
        body: Consumer<RestaurantProvider>(
          builder: (context, provider, _) {
            final state = provider.state;

            return RefreshIndicator(
              onRefresh: provider.load,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    snap: false,
                    title: const Text('Restaurants'),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(64),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: DebouncedSearchField(
                          hintText: 'Search restaurants...',
                          onChanged: provider.search,
                        ),
                      ),
                    ),
                  ),
                  if (state is ApiLoading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(6, (i) => i)
                              .map((_) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Row(
                                        children: [
                                          Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(height: 16, width: double.infinity, color: Colors.white),
                                                const SizedBox(height: 8),
                                                Container(height: 14, width: 180, color: Colors.white),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    )
                  else if (state is ApiError<List<RestaurantSummary>>)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 48),
                              const SizedBox(height: 12),
                              Text('Failed to load data.\n${state.message}', textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: provider.load,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    Builder(
                      builder: (context) {
                        final data = (state as ApiData<List<RestaurantSummary>>).value;
                        if (data.isEmpty) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text('No restaurants found')),
                          );
                        }
                        return SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.crossAxisExtent;
                            if (width >= 800) {
                              int cols = 2;
                              if (width >= 1200) cols = 4; else if (width >= 1000) cols = 3;
                              return SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                sliver: SliverGrid(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: cols,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 3 / 2,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final r = data[index];
                                      final imgUrl = RestaurantApiService().imageUrl(r.pictureId);
                                      return _RestaurantCard(
                                        name: r.name,
                                        city: r.city,
                                        rating: r.rating,
                                        imageUrl: imgUrl,
                                        heroTag: 'api_rest_img_${r.id}',
                                        onTap: () => Navigator.of(context).pushNamed('/api_detail', arguments: {
                                          'id': r.id,
                                          'name': r.name,
                                          'imgTag': 'api_rest_img_${r.id}',
                                          'imgUrl': imgUrl,
                                        }),
                                      );
                                    },
                                    childCount: data.length,
                                  ),
                                ),
                              );
                            }
                            // Fallback to list for narrow screens
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index.isOdd) return const Divider(height: 1);
                                  final itemIndex = index ~/ 2;
                                  if (itemIndex >= data.length) return null;
                                  final r = data[itemIndex];
                                  final imgUrl = RestaurantApiService().imageUrl(r.pictureId);
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    minVerticalPadding: 12,
                                    leading: Hero(
                                      tag: 'api_rest_img_${r.id}',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: imgUrl,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          placeholder: (c, _) => Container(color: Colors.black12),
                                          errorWidget: (c, _, __) => const Icon(Icons.broken_image_rounded),
                                        ),
                                      ),
                                    ),
                                    title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    subtitle: Row(
                                      children: [
                                        const Icon(Icons.place_rounded, size: 16),
                                        const SizedBox(width: 4),
                                        Flexible(child: Text(r.city, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(r.rating.toStringAsFixed(1)),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.chevron_right_rounded),
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/api_detail', arguments: {
                                        'id': r.id,
                                        'name': r.name,
                                        'imgTag': 'api_rest_img_${r.id}',
                                        'imgUrl': imgUrl,
                                      });
                                    },
                                  );
                                },
                                childCount: data.isEmpty ? 0 : (data.length * 2 - 1),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.name,
    required this.city,
    required this.rating,
    required this.imageUrl,
    required this.heroTag,
    required this.onTap,
  });

  final String name;
  final String city;
  final double rating;
  final String imageUrl;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: const [BoxShadow(color: Color(0x140B0F1A), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (c, _) => Container(color: Colors.black12),
                      errorWidget: (c, _, __) => const Icon(Icons.broken_image_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 16),
                  const SizedBox(width: 4),
                  Expanded(child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 12),
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}