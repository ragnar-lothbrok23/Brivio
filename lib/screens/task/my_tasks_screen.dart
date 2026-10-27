import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/status_chip.dart';
import '../widgets/tappable_card.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  final _taskService = TaskService();
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.streamTasksForUser(widget.user.uid),
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
                    message: allTasks.isEmpty
                        ? 'No tasks assigned to you yet'
                        : 'No tasks match this filter',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final lines = [
                      if (task.description.isNotEmpty) task.description,
                      if (task.dueDate != null)
                        task.isOverdue ? 'Due ${task.dueDate} (overdue)' : 'Due ${task.dueDate}',
                    ];
                    return TappableCard(
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StatusChip(status: task.status),
                            ),
                            if (lines.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  lines.join('\n'),
                                  style: task.isOverdue ? const TextStyle(color: Colors.red) : null,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: lines.length > 1,
                        trailing: _StatusAction(task: task, taskService: _taskService),
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

class _StatusAction extends StatelessWidget {
  const _StatusAction({required this.task, required this.taskService});

  final Task task;
  final TaskService taskService;

  @override
  Widget build(BuildContext context) {
    switch (task.status) {
      case 'assigned':
        return TextButton(
          onPressed: () => taskService.updateStatus(task.id, 'in_progress'),
          child: const Text('Start'),
        );
      case 'in_progress':
        return TextButton(
          onPressed: () => taskService.updateStatus(task.id, 'completed'),
          child: const Text('Complete'),
        );
      default:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }
}
