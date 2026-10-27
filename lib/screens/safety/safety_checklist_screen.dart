import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../models/safety_checklist.dart';
import '../../services/notification_service.dart';
import '../../services/project_service.dart';
import '../../services/safety_checklist_service.dart';
import '../../services/user_service.dart';
import '../../utils/date_format.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';

class SafetyChecklistScreen extends StatefulWidget {
  const SafetyChecklistScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<SafetyChecklistScreen> createState() => _SafetyChecklistScreenState();
}

class _SafetyChecklistScreenState extends State<SafetyChecklistScreen> {
  final _projectService = ProjectService();
  final _checklistService = SafetyChecklistService();
  final _notificationService = NotificationService();
  final _userService = UserService();

  Project? _selectedProject;

  Future<void> _showNewChecklistDialog(BuildContext context, String projectId) async {
    final notesController = TextEditingController();
    final checked = {for (final item in kSafetyChecklistItems) item: false};

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('New Safety Checklist'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final item in kSafetyChecklistItems)
                        CheckboxListTile(
                          title: Text(item),
                          value: checked[item],
                          onChanged: (value) =>
                              setDialogState(() => checked[item] = value ?? false),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: notesController,
                          decoration: const InputDecoration(labelText: 'Notes (optional)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _checklistService.submitChecklist(
                      projectId: projectId,
                      conductedByUid: widget.user.uid,
                      conductedByName: widget.user.name,
                      date: formatDate(DateTime.now()),
                      items: [
                        for (final item in kSafetyChecklistItems)
                          SafetyChecklistItem(label: item, checked: checked[item] ?? false),
                      ],
                      notes: notesController.text.trim(),
                    );
                    final recipients = await _userService.getUidsForRoles(['builder', 'pm']);
                    await _notificationService.sendToMany(
                      recipientUids: recipients,
                      type: 'safety_checklist_submitted',
                      title: 'Safety checklist submitted',
                      body: '${widget.user.name} submitted a safety checklist.',
                      projectId: projectId,
                      relatedCollection: 'safety_checklists',
                    );
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConduct = widget.user.isSiteEngineer || widget.user.isSupervisor;
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Checklists')),
      floatingActionButton: (canConduct && _selectedProject != null)
          ? FloatingActionButton(
              onPressed: () => _showNewChecklistDialog(context, _selectedProject!.id),
              child: const Icon(Icons.checklist_rtl),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectPickerField(
            projectsStream: _projectService.streamProjectsForUser(widget.user),
            onChanged: (project) => setState(() => _selectedProject = project),
          ),
          if (_selectedProject != null)
            Expanded(
              child: StreamBuilder<List<SafetyChecklist>>(
                stream: _checklistService.streamForProject(_selectedProject!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonList();
                  }
                  final checklists = snapshot.data!;
                  if (checklists.isEmpty) {
                    return const EmptyState(
                      icon: Icons.checklist_rtl_outlined,
                      message: 'No safety checklists yet',
                    );
                  }
                  return ListView.builder(
                    itemCount: checklists.length,
                    itemBuilder: (context, index) {
                      final checklist = checklists[index];
                      final passedCount = checklist.items.where((item) => item.checked).length;
                      return ExpansionTile(
                        title: Text('${checklist.date} • ${checklist.conductedByName}'),
                        subtitle: Text('$passedCount/${checklist.items.length} checked'),
                        children: [
                          for (final item in checklist.items)
                            ListTile(
                              leading: Icon(
                                item.checked ? Icons.check_circle : Icons.cancel,
                                color: item.checked ? Colors.green : Colors.red,
                              ),
                              title: Text(item.label),
                            ),
                          if (checklist.notes.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('Notes: ${checklist.notes}'),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
