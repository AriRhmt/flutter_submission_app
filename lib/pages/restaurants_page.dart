import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../states/api_state.dart';
import '../services/restaurant_api_service.dart';
import '../models/restaurant_summary.dart';
import '../widgets/debounced_search_field.dart';
import 'package:shimmer/shimmer.dart';

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

            return CustomScrollView(
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
                else if (state is ApiError<List>)
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
                              leading: Hero(
                                tag: 'api_rest_img_${r.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(imgUrl, width: 64, height: 64, fit: BoxFit.cover),
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
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}