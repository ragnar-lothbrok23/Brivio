import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../services/auth_service.dart';
import '../../services/project_service.dart';
import '../attendance/labor_attendance_screen.dart';
import '../chat/project_chat_screen.dart';
import '../inventory/inventory_screen.dart';
import '../profile/profile_screen.dart';
import '../safety/safety_checklist_screen.dart';
import '../task/my_tasks_screen.dart';
import '../widgets/check_in_button.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/notification_bell.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/tappable_card.dart';
import '../worker/progress_log_screen.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<SupervisorDashboardScreen> createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  final _projectService = ProjectService();
  Project? _selectedProject;

  // Only Home (0) and More (3) are real tab states; Attendance (1) and My
  // Tasks (2) are shortcuts that push a screen.
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
        icon: Icons.checklist_rtl,
        label: l10n.safetyChecklists,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SafetyChecklistScreen(user: widget.user)),
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
        icon: Icons.add_a_photo,
        label: l10n.myProgressLog,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProgressLogScreen(user: widget.user)),
          );
        },
      ),
    ];
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LaborAttendanceScreen(user: widget.user)),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MyTasksScreen(user: widget.user)),
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
        ProjectPickerField(
          projectsStream: _projectService.streamProjectsForUser(widget.user),
          onChanged: (project) => setState(() => _selectedProject = project),
        ),
        CheckInButton(user: widget.user, projectId: _selectedProject?.id),
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
    final user = widget.user;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supervisorDashboard),
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
      body: _navIndex == 3 ? _buildMore() : _buildHome(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex == 3 ? 3 : 0,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: user.accentColor.withValues(alpha: 0.18),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(icon: const Icon(Icons.how_to_reg_outlined), label: l10n.attendance),
          NavigationDestination(icon: const Icon(Icons.checklist_outlined), label: l10n.myTasks),
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
