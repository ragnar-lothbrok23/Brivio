import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/labor_attendance_record.dart';
import '../../models/laborer.dart';
import '../../models/project.dart';
import '../../services/labor_attendance_service.dart';
import '../../services/laborer_service.dart';
import '../../services/project_service.dart';
import '../../utils/date_format.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';

class LaborAttendanceScreen extends StatefulWidget {
  const LaborAttendanceScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<LaborAttendanceScreen> createState() => _LaborAttendanceScreenState();
}

class _LaborAttendanceScreenState extends State<LaborAttendanceScreen> {
  final _projectService = ProjectService();
  final _laborerService = LaborerService();
  final _laborAttendanceService = LaborAttendanceService();
  late final String _today = formatDate(DateTime.now());

  Project? _selectedProject;

  Future<void> _showAddLaborerDialog(BuildContext context, String projectId) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Laborer'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Enter a name' : null,
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
                await _laborerService.addLaborer(
                  projectId: projectId,
                  name: nameController.text.trim(),
                  addedBy: widget.user.uid,
                );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Labor Attendance')),
      floatingActionButton: _selectedProject == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddLaborerDialog(context, _selectedProject!.id),
              child: const Icon(Icons.person_add_alt_1),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Today ($_today)', style: Theme.of(context).textTheme.titleMedium),
            ),
          if (_selectedProject != null)
            Expanded(
              child: StreamBuilder<List<Laborer>>(
                stream: _laborerService.streamLaborers(_selectedProject!.id),
                builder: (context, laborersSnapshot) {
                  if (!laborersSnapshot.hasData) {
                    return const SkeletonList();
                  }
                  final laborers = laborersSnapshot.data!;
                  if (laborers.isEmpty) {
                    return const EmptyState(
                      icon: Icons.groups_outlined,
                      message: 'No laborers added yet',
                    );
                  }
                  return StreamBuilder<List<LaborAttendanceRecord>>(
                    stream: _laborAttendanceService.streamForProject(_selectedProject!.id),
                    builder: (context, attendanceSnapshot) {
                      final todaysStatus = <String, String>{
                        for (final record
                            in attendanceSnapshot.data ?? <LaborAttendanceRecord>[])
                          if (record.date == _today) record.laborerId: record.status,
                      };
                      return ListView.builder(
                        itemCount: laborers.length,
                        itemBuilder: (context, index) {
                          final laborer = laborers[index];
                          final status = todaysStatus[laborer.id];
                          return ListTile(
                            title: Text(laborer.name),
                            subtitle: Text(status == null ? 'Not marked yet' : 'Marked: $status'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: status == 'Present' ? Colors.green : Colors.grey,
                                  ),
                                  onPressed: () => _mark(laborer, 'Present'),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: status == 'Absent' ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () => _mark(laborer, 'Absent'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _laborerService.removeLaborer(
                                    _selectedProject!.id,
                                    laborer.id,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

  Future<void> _mark(Laborer laborer, String status) {
    return _laborAttendanceService.markAttendance(
      projectId: _selectedProject!.id,
      laborerId: laborer.id,
      laborerName: laborer.name,
      date: _today,
      status: status,
    );
  }
}
