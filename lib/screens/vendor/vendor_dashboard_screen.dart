import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../chat/project_chat_screen.dart';
import '../profile/profile_screen.dart';
import '../purchase_order/purchase_order_screen.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/notification_bell.dart';
import '../widgets/profile_avatar.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key, required this.user});

  final AppUser user;

  // Home is the dashboard's only real tab; Purchase Orders and Team Chat
  // both push a screen, so the bar's selection never actually moves off Home.
  void _onDestinationSelected(BuildContext context, int index) {
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PurchaseOrderScreen(user: user)),
      );
    } else if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProjectChatScreen(user: user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vendorDashboard),
        backgroundColor: user.accentColor,
        foregroundColor: Colors.white,
        actions: [
          NotificationBell(user: user),
          IconButton(
            icon: ProfileAvatar(user: user),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProfileScreen(user: user)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().logOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [DashboardHeader(user: user)],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
        indicatorColor: user.accentColor.withValues(alpha: 0.18),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_shipping_outlined),
            label: l10n.purchaseOrders,
          ),
          NavigationDestination(icon: const Icon(Icons.forum_outlined), label: l10n.teamChat),
        ],
      ),
    );
  }
}
