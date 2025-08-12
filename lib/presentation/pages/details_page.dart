import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../state/providers/example_provider.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExampleProvider>();
    final item = provider.getById(id);
    if (item == null) {
      return const Scaffold(body: Center(child: Text('Item not found')));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'image_${item.id}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF0F2FF)),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(item.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                AppSpacing.lg.hspace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
                    AppSpacing.xs.vspace,
                    Text(item.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                )
              ],
            ),
            AppSpacing.xxl.vspace,
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            AppSpacing.md.vspace,
            Text(
              'Keep consistent logs of your ${item.title.toLowerCase()} to see trends and insights similar to Diabite\'s visuals. This is a sample details screen with clean layout and subtle motion.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            )
          ],
        ),
      ),
    );
  }
}