import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../services/auth_service.dart';
import '../../services/project_service.dart';
import '../chat/project_chat_screen.dart';
import '../contractor_invoice/contractor_invoice_screen.dart';
import '../profile/profile_screen.dart';
import '../widgets/check_in_button.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/notification_bell.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/project_picker_field.dart';
import '../worker/progress_log_screen.dart';

class ContractorDashboardScreen extends StatefulWidget {
  const ContractorDashboardScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ContractorDashboardScreen> createState() => _ContractorDashboardScreenState();
}

class _ContractorDashboardScreenState extends State<ContractorDashboardScreen> {
  final _projectService = ProjectService();
  Project? _selectedProject;

  // Home is the only real tab; the other three destinations push a screen,
  // so the bar's selection never actually moves off Home.
  void _onDestinationSelected(int index) {
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProgressLogScreen(user: widget.user)),
      );
    } else if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ContractorInvoiceScreen(user: widget.user)),
      );
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProjectChatScreen(user: widget.user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contractorDashboard),
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
        children: [
          DashboardHeader(user: user),
          ProjectPickerField(
            projectsStream: _projectService.streamProjectsForUser(user),
            onChanged: (project) => setState(() => _selectedProject = project),
          ),
          if (_selectedProject != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                (_selectedProject!.contractorScopes[user.uid] ?? '').isEmpty
                    ? l10n.noScopeSet
                    : l10n.scopePrefix(_selectedProject!.contractorScopes[user.uid]!),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          CheckInButton(user: user, projectId: _selectedProject?.id),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: user.accentColor.withValues(alpha: 0.18),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(icon: const Icon(Icons.add_a_photo_outlined), label: l10n.progress),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: l10n.invoices),
          NavigationDestination(icon: const Icon(Icons.forum_outlined), label: l10n.teamChat),
        ],
      ),
    );
  }
}
