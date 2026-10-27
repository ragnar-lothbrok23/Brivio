import 'package:flutter/material.dart';

/// Large construction-themed graphic shown right below the header — the
/// dominant visual on the dashboard, not boxed in a separate card.
class DashboardHeroGraphic extends StatelessWidget {
  const DashboardHeroGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Image.asset(
        'assets/images/pngegg.png',
        height: 280,
        fit: BoxFit.contain,
      ),
    );
  }
}
