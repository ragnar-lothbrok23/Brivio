import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';
import '../../services/project_service.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../../utils/date_format.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/status_chip.dart';
import '../widgets/tappable_card.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _projectService = ProjectService();
  final _taskService = TaskService();
  final _userService = UserService();
  final _notificationService = NotificationService();

  Project? _selectedProject;
  String? _statusFilter;

  Future<void> _showAssignTaskDialog(BuildContext context, String projectId) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedSupervisorUid;
    String? selectedSupervisorName;
    DateTime? dueDate;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Assign Task'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<List<AppUser>>(
                        stream: _userService.streamUsersForProject(projectId),
                        builder: (context, snapshot) {
                          final supervisors = (snapshot.data ?? const <AppUser>[])
                              .where((u) => u.isSupervisor)
                              .toList();
                          if (supervisors.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('No Supervisor assigned to this project yet'),
                            );
                          }
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Assign to'),
                            items: [
                              for (final supervisor in supervisors)
                                DropdownMenuItem(
                                  value: supervisor.uid,
                                  child: Text(supervisor.name),
                                ),
                            ],
                            onChanged: (value) {
                              selectedSupervisorUid = value;
                              selectedSupervisorName =
                                  supervisors.firstWhere((s) => s.uid == value).name;
                            },
                            validator: (value) => value == null ? 'Pick a supervisor' : null,
                          );
                        },
                      ),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Task title'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Enter a title' : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dueDate == null
                                ? 'No due date'
                                : 'Due: ${formatDate(dueDate!)}',
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: dueDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) setDialogState(() => dueDate = picked);
                            },
                            child: const Text('Set due date'),
                          ),
                        ],
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
                    if (!formKey.currentState!.validate()) return;
                    await _taskService.createTask(
                      projectId: projectId,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      assignedToUid: selectedSupervisorUid!,
                      assignedToName: selectedSupervisorName!,
                      createdBy: widget.user.uid,
                      dueDate: dueDate == null ? null : formatDate(dueDate!),
                    );
                    await _notificationService.send(
                      recipientUid: selectedSupervisorUid!,
                      type: 'task_assigned',
                      title: 'New task assigned',
                      body: titleController.text.trim(),
                      projectId: projectId,
                      relatedCollection: 'tasks',
                    );
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Assign'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: _selectedProject == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAssignTaskDialog(context, _selectedProject!.id),
              child: const Icon(Icons.add_task),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectPickerField(
            projectsStream: _projectService.streamProjectsForUser(widget.user),
            onChanged: (project) => setState(() => _selectedProject = project),
          ),
          if (_selectedProject != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _statusFilter == null,
                    onSelected: (_) => setState(() => _statusFilter = null),
                  ),
                  for (final entry in kTaskStatusLabels.entries)
                    ChoiceChip(
                      label: Text(entry.value),
                      selected: _statusFilter == entry.key,
                      onSelected: (_) => setState(() => _statusFilter = entry.key),
                    ),
                ],
              ),
            ),
          if (_selectedProject != null)
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: _taskService.streamTasksForProject(_selectedProject!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonList();
                  }
                  final allTasks = snapshot.data!;
                  final tasks = _statusFilter == null
                      ? allTasks
                      : allTasks.where((t) => t.status == _statusFilter).toList();
                  if (tasks.isEmpty) {
                    return EmptyState(
                      icon: Icons.task_outlined,
                      message:
                          allTasks.isEmpty ? 'No tasks assigned yet' : 'No tasks match this filter',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TappableCard(
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(
                            task.dueDate == null
                                ? 'Assigned to ${task.assignedToName}'
                                : 'Assigned to ${task.assignedToName} • Due ${task.dueDate}',
                            style: task.isOverdue ? const TextStyle(color: Colors.red) : null,
                          ),
                          trailing: StatusChip(status: task.status),
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
  }
}
