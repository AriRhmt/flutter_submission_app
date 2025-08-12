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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          title: Text(title),
          backgroundColor: Colors.white.withOpacity(0.6),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.08),
          surfaceTintColor: Colors.transparent,
          actions: actions,
        ),
      ),
    );
  }
}