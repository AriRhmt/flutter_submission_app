import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text('Diabite'),
        actions: const [
          _Avatar(),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: child,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200'),
        ),
      ),
    );
  }
}