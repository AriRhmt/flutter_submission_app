import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_detail_provider.dart';
import '../states/api_state.dart';
import '../services/restaurant_api_service.dart';
import '../models/restaurant_detail.dart';

class ApiDetailPage extends StatefulWidget {
  const ApiDetailPage({super.key});

  @override
  State<ApiDetailPage> createState() => _ApiDetailPageState();
}

class _ApiDetailPageState extends State<ApiDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;
    final String id = args['id'] as String;
    final String? name = args['name'] as String?;
    final String? imgTag = args['imgTag'] as String?;
    final String? imgUrl = args['imgUrl'] as String?;

    return ChangeNotifierProvider(
      create: (_) => RestaurantDetailProvider(api: RestaurantApiService())..load(id),
      child: Scaffold(
        appBar: AppBar(title: Text(name ?? 'Details')),
        body: Consumer<RestaurantDetailProvider>(
          builder: (context, provider, _) {
            final state = provider.state;

            if (state is ApiLoading<RestaurantDetail>) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ApiError<RestaurantDetail>) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48),
                      const SizedBox(height: 12),
                      Text('Failed to load detail.\n${state.message}', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => provider.load(id),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final detail = (state as ApiData<RestaurantDetail>).value;
            final image = imgUrl ?? RestaurantApiService().imageUrl(detail.pictureId, size: 'large');

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => provider.load(id),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      Hero(
                        tag: imgTag ?? 'api_rest_img_${detail.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(image, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(detail.name, style: Theme.of(context).textTheme.headlineMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.place_rounded, size: 18),
                            const SizedBox(width: 6),
                            Flexible(child: Text('${detail.city} • ${detail.address}')),
                            const SizedBox(width: 12),
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 6),
                            Text(detail.rating.toStringAsFixed(1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(detail.description, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const SizedBox(height: 16),

                      _SectionTitle(title: 'Menus'),
                      _MenuChips(title: 'Foods', items: detail.menus.foods.map((e) => e.name).toList()),
                      _MenuChips(title: 'Drinks', items: detail.menus.drinks.map((e) => e.name).toList()),

                      _SectionTitle(title: 'Customer Reviews'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: detail.customerReviews.map((r) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person_rounded, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(r.name,
                                              style: Theme.of(context).textTheme.titleLarge,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        Text(r.date, style: Theme.of(context).textTheme.bodyMedium),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(r.review),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      _SectionTitle(title: 'Add Your Review'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Your name',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Please enter your name';
                                  if (v.trim().length < 2) return 'Too short';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _reviewCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Write your review...',
                                  prefixIcon: Icon(Icons.edit_rounded),
                                ),
                                minLines: 2,
                                maxLines: 4,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Please write a review';
                                  if (v.trim().length < 5) return 'Describe a bit more';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: provider.submitting
                                      ? null
                                      : () async {
                                          if (!_formKey.currentState!.validate()) return;
                                          await provider.submitReview(
                                            id: detail.id,
                                            name: _nameCtrl.text.trim(),
                                            review: _reviewCtrl.text.trim(),
                                          );
                                          if (provider.submitError != null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(provider.submitError!)),
                                            );
                                          } else {
                                            _nameCtrl.clear();
                                            _reviewCtrl.clear();
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Review submitted')),
                                              );
                                            }
                                          }
                                        },
                                  icon: const Icon(Icons.send_rounded),
                                  label: const Text('Submit Review'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.submitting)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: false,
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _MenuChips extends StatelessWidget {
  const _MenuChips({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('No $title available', style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((e) => Chip(label: Text(e))).toList(),
          ),
        ],
      ),
    );
  }
}