import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/example_model.dart';

class HealthCard extends StatefulWidget {
  const HealthCard({super.key, required this.item, required this.onTap});

  final HealthItem item;
  final VoidCallback onTap;

  @override
  State<HealthCard> createState() => _HealthCardState();
}

class _HealthCardState extends State<HealthCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: _hovered ? 18 : 10,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'image_${widget.item.id}',
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF0F2FF),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(widget.item.imageUrl, fit: BoxFit.cover),
                      ),
                    ),
                    AppSpacing.lg.hspace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(widget.item.title, style: Theme.of(context).textTheme.titleLarge),
                          ),
                          AppSpacing.xs.vspace,
                          Text(widget.item.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.xl.vspace,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          widget.item.value,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                    AppSpacing.sm.hspace,
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          widget.item.unit,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}