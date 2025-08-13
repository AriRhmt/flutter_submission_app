import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../states/api_state.dart';
import '../services/restaurant_api_service.dart';

class RestaurantsPage extends StatelessWidget {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestaurantProvider(api: RestaurantApiService())..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Restaurants')),
        body: Consumer<RestaurantProvider>(
          builder: (context, provider, _) {
            final state = provider.state;

            if (state is ApiLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ApiError<List>) {
              return Center(
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
              );
            }

            final data = (state as ApiData<List>).value as List; // List<RestaurantSummary>
            return RefreshIndicator(
              onRefresh: provider.load,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search restaurants...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onChanged: provider.search,
                      ),
                    ),
                  ),
                  SliverList.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = data[index];
                      final imgUrl = RestaurantApiService().imageUrl(r.pictureId);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Hero(
                          tag: 'rest_img_${r.id}',
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
                          Navigator.of(context).pushNamed('/detail', arguments: {
                            'id': r.id,
                            'name': r.name,
                            'imgTag': 'rest_img_${r.id}',
                            'imgUrl': imgUrl,
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}