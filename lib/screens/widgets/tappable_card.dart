import 'package:flutter/material.dart';

/// A rounded, soft-shadow card for list rows — the app's global CardTheme
/// is flat (elevation 0) for the reference look, so list items that need
/// to visually "pop" (projects, tasks, etc.) use this instead of a bare
/// ListTile or the default Card.
class TappableCard extends StatelessWidget {
  const TappableCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }
}
