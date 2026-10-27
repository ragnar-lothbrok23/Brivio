import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../admin/attendance_overview_screen.dart';
import '../admin/progress_log_overview_screen.dart';
import '../chat/project_chat_screen.dart';
import '../contractor_invoice/contractor_invoice_screen.dart';
import '../expense/expense_screen.dart';
import '../inventory/inventory_screen.dart';
import '../profile/profile_screen.dart';
import '../project/project_screen.dart';
import '../safety/safety_checklist_screen.dart';
import '../summary/project_summary_body.dart';
import '../summary/summary_screen.dart';
import '../timeline/photo_timeline_screen.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_hero_graphic.dart';
import '../widgets/notification_bell.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/tappable_card.dart';

class BuilderDashboardScreen extends StatefulWidget {
  const BuilderDashboardScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<BuilderDashboardScreen> createState() => _BuilderDashboardScreenState();
}

class _BuilderDashboardScreenState extends State<BuilderDashboardScreen> {
  // Only Home (0) and More (3) are real tab states with their own body;
  // Projects (1) and Expenses (2) are shortcuts that push a screen, so
  // _navIndex never actually becomes 1 or 2 — see _onDestinationSelected.
  int _navIndex = 0;

  List<DashboardDrawerItem> _moreItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      DashboardDrawerItem(
        icon: Icons.forum,
        label: l10n.teamChat,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProjectChatScreen(user: widget.user)),
          );
        },
      ),
      DashboardDrawerItem(
        icon: Icons.dashboard,
        label: l10n.projectSummary,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SummaryScreen(user: widget.user)),
          );
        },
      ),
      DashboardDrawerItem(
        icon: Icons.event_available,
        label: l10n.attendanceOverview,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AttendanceOverviewScreen()),
          );
        },
      ),
      DashboardDrawerItem(
        icon: Icons.assignment,
        label: l10n.progressLogs,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProgressLogOverviewScreen()),
          );
        },
      ),
      DashboardDrawerItem(
        icon: Icons.photo_library,
        label: l10n.photoTimeline,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PhotoTimelineScreen(user: widget.user)),
          );
        },
      ),
      DashboardDrawerItem(
        icon: Icons.inventory_2,
        label: l10n.materialInventory,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => InventoryScreen(user: widget.user)),
          );
        },
      ),
      DashboardDrawerItem(
        icon: Icons.checklist_rtl,
        label: l10n.safetyChecklists,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SafetyChecklistScreen(user: widget.user)),
          );
        },
      ),
      DashboardDrawerItem(
        icon: Icons.receipt_long,
        label: l10n.contractorInvoices,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ContractorInvoiceScreen(user: widget.user)),
          );
        },
      ),
    ];
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProjectScreen(currentUserUid: widget.user.uid)),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ExpenseScreen(user: widget.user)),
        );
        break;
      default:
        setState(() => _navIndex = index);
    }
  }

  Widget _buildHome() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        DashboardHeader(user: widget.user),
        const DashboardHeroGraphic(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            AppLocalizations.of(context)!.projectSummary,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        ProjectSummaryBody(user: widget.user),
      ],
    );
  }

  Widget _buildMore() {
    final items = _moreItems(context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return TappableCard(
          onTap: item.onTap,
          child: ListTile(
            leading: Icon(item.icon, color: widget.user.accentColor),
            title: Text(item.label),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.builderDashboard),
        backgroundColor: widget.user.accentColor,
        foregroundColor: Colors.white,
        actions: [
          NotificationBell(user: widget.user),
          IconButton(
            icon: ProfileAvatar(user: widget.user),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.user)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().logOut(),
          ),
        ],
      ),
      body: _navIndex == 3 ? _buildMore() : _buildHome(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex == 3 ? 3 : 0,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: widget.user.accentColor.withValues(alpha: 0.18),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(icon: const Icon(Icons.apartment_outlined), label: l10n.projects),
          NavigationDestination(icon: const Icon(Icons.currency_rupee), label: l10n.expenses),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.more,
          ),
        ],
      ),
    );
  }
}
