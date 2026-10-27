import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../services/user_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_list.dart';

class ProjectDetailScreen extends StatelessWidget {
  ProjectDetailScreen({super.key, required this.project});

  final Project project;
  final _userService = UserService();
  final _projectService = ProjectService();

  Future<void> _showAssignUserDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Assign Users'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: StreamBuilder<List<AppUser>>(
              stream: _userService.streamAssignableUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!;
                if (users.isEmpty) {
                  return const Center(
                    child: Text('No Site Engineer, Supervisor, Contractor, or Vendor accounts yet'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isAssigned = user.assignedProjectIds.contains(project.id);
                    return CheckboxListTile(
                      title: Text(user.name),
                      subtitle: Text(user.roleLabel),
                      value: isAssigned,
                      onChanged: (checked) {
                        if (checked == true) {
                          _userService.assignToProject(user.uid, project.id);
                        } else {
                          _userService.unassignFromProject(user.uid, project.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditLocationDialog(BuildContext context, String currentLocation) async {
    final controller = TextEditingController(text: currentLocation);
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Project Location'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Location (city)',
                  helperText: 'Used to show weather on the Progress Log screen',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          await _projectService.updateLocation(project.id, controller.text);
                          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditScopeDialog(
    BuildContext context,
    AppUser contractor,
    String currentScope,
  ) async {
    final controller = TextEditingController(text: currentScope);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Scope of Work — ${contractor.name}'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Describe their assigned scope'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _projectService.setContractorScope(
                  project.id,
                  contractor.uid,
                  controller.text.trim(),
                );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Project?>(
      stream: _projectService.streamProject(project.id),
      builder: (context, projectSnapshot) {
        final liveProject = projectSnapshot.data ?? project;
        return Scaffold(
          appBar: AppBar(
            title: Text(project.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.location_on_outlined),
                tooltip: 'Edit location',
                onPressed: () => _showEditLocationDialog(context, liveProject.location),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAssignUserDialog(context),
            child: const Icon(Icons.person_add),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${liveProject.client} · Budget ₹${liveProject.budget.toStringAsFixed(0)}'
                  '${liveProject.location.isNotEmpty ? ' · ${liveProject.location}' : ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Assigned team', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: StreamBuilder<List<AppUser>>(
                  stream: _userService.streamUsersForProject(project.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SkeletonList();
                    }
                    final users = snapshot.data!;
                    if (users.isEmpty) {
                      return const EmptyState(
                        icon: Icons.people_outline,
                        message: 'No one assigned yet',
                      );
                    }
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final scope = liveProject.contractorScopes[user.uid] ?? '';
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text(
                            user.isContractor && scope.isNotEmpty
                                ? '${user.roleLabel} • $scope'
                                : user.roleLabel,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user.isContractor)
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _showEditScopeDialog(context, user, scope),
                                ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () =>
                                    _userService.unassignFromProject(user.uid, project.id),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
