import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import 'pressable_scale.dart';
import 'profile_avatar.dart';

class DashboardDrawerItem {
  const DashboardDrawerItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Left-side navigation drawer for a dashboard — replaces the inline
/// icon grid with a slide-out menu, so the hero image dominates the
/// screen on login.
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key, required this.user, required this.items});

  final AppUser user;
  final List<DashboardDrawerItem> items;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Row(
              children: [
                ProfileAvatar(user: user, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizedRoleLabel(context, user.role),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final item in items)
            PressableScale(
              onTap: () {
                Navigator.pop(context);
                item.onTap();
              },
              child: ListTile(
                leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
                title: Text(item.label),
              ),
            ),
        ],
      ),
    );
  }
}
