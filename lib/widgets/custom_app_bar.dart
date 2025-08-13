import 'dart:ui';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title, this.actions});
  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surface;
    final Color shadow = Colors.black.withOpacity(0.08);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          title: Text(title),
          backgroundColor: surface.withOpacity(0.85),
          elevation: 6,
          shadowColor: shadow,
          surfaceTintColor: Colors.transparent,
          actions: actions,
        ),
      ),
    );
  }
}