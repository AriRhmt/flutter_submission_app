import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';
import '../../state/providers/example_provider.dart';
import '../widgets/health_card.dart';
import 'details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ExampleProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = Responsive.gridColumnsForWidth(width);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _Header()),
            SliverPadding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              sliver: const SliverToBoxAdapter(child: _QuickActions()),
            ),
            Selector<ExampleProvider, ({bool loading, int count})>(
              selector: (_, p) => (loading: p.isLoading, count: p.items.length),
              builder: (context, state, _) {
                if (state.loading && state.count == 0) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                    ),
                  );
                }
                final items = context.read<ExampleProvider>().items;
                return SliverPadding(
                  padding: const EdgeInsets.only(top: 12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        return HealthCard(
                          item: item,
                          onTap: () {
                            Navigator.of(context).push(_DetailsRoute(item.id));
                          },
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good afternoon', style: Theme.of(context).textTheme.bodyMedium),
        AppSpacing.xs.vspace,
        Text('Track your health', style: Theme.of(context).textTheme.displayMedium),
        AppSpacing.lg.vspace,
        TextField(
          decoration: InputDecoration(
            hintText: 'Search logs, meals, meds... ',
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: const [
          _Chip(text: 'Today'),
          SizedBox(width: 10),
          _Chip(text: 'Week'),
          SizedBox(width: 10),
          _Chip(text: 'Insights'),
          SizedBox(width: 10),
          _Chip(text: 'Reminders'),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Center(
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

class _DetailsRoute extends PageRouteBuilder {
  _DetailsRoute(this.id)
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (context, animation, secondaryAnimation) => _FadeSlideTransition(
            animation: animation,
            child: DetailsPage(id: id),
          ),
        );
  final String id;
}

class _FadeSlideTransition extends StatelessWidget {
  const _FadeSlideTransition({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final offset = Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return FadeTransition(opacity: fade, child: SlideTransition(position: offset, child: child));
  }
}

