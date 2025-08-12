import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/favorite_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _favoriteService = FavoriteService();
  bool _isFav = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final r = ModalRoute.of(context)!.settings.arguments as Restaurant?;
    if (r != null) {
      _favoriteService.isFavorite(r.id).then((v) => setState(() => _isFav = v));
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant?;
    if (restaurant == null) {
      return const Scaffold(body: SafeArea(child: Center(child: Text('Not found'))));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        actions: [
          IconButton(
            icon: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.pinkAccent),
            onPressed: () async {
              await _favoriteService.toggleFavorite({
                'id': restaurant.id,
                'name': restaurant.name,
                'city': restaurant.city,
                'rating': restaurant.rating,
                'description': restaurant.description,
                'image': restaurant.image,
              });
              final v = await _favoriteService.isFavorite(restaurant.id);
              setState(() => _isFav = v);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'rest_${restaurant.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(imageUrl: restaurant.image, fit: BoxFit.cover, placeholder: (c,_)=>Container(color: Colors.black12), errorWidget: (c,_,__)=>(const Icon(Icons.broken_image_rounded))),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(restaurant.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 18),
                const SizedBox(width: 6),
                Text(restaurant.city),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber),
                const SizedBox(width: 6),
                Text(restaurant.rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 16),
            Text(restaurant.description, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}