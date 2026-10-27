import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/app_user.dart';

/// Bold "Welcome, name" heading shown at the top of every dashboard, sitting
/// directly on the app's cream background. The role label is a small pill in
/// the user's role accent color, so each role reads as visually distinct.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.welcomeUser(user.name),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: user.accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              localizedRoleLabel(context, user.role),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: user.accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
