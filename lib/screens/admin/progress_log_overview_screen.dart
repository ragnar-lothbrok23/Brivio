import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/progress_log.dart';
import '../../models/project.dart';
import '../../services/progress_log_service.dart';
import '../../services/project_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../widgets/skeleton_list.dart';

class ProgressLogOverviewScreen extends StatefulWidget {
  const ProgressLogOverviewScreen({super.key});

  @override
  State<ProgressLogOverviewScreen> createState() => _ProgressLogOverviewScreenState();
}

class _ProgressLogOverviewScreenState extends State<ProgressLogOverviewScreen> {
  final _progressLogService = ProgressLogService();
  final _projectService = ProjectService();

  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Logs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<List<Project>>(
              stream: _projectService.streamAllProjects(),
              builder: (context, snapshot) {
                final projects = snapshot.data ?? const <Project>[];
                return DropdownButtonFormField<String?>(
                  initialValue: _selectedProjectId,
                  decoration: const InputDecoration(labelText: 'Project'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Projects')),
                    for (final project in projects)
                      DropdownMenuItem(value: project.id, child: Text(project.name)),
                  ],
                  onChanged: (value) => setState(() => _selectedProjectId = value),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProgressLog>>(
              stream: _progressLogService.streamAllLogs(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SkeletonList();
                }
                final logs = _selectedProjectId == null
                    ? snapshot.data!
                    : snapshot.data!.where((log) => log.projectId == _selectedProjectId).toList();
                if (logs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.assignment_outlined,
                    message: 'No progress logs yet',
                  );
                }
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return ListTile(
                      leading: log.hasPhoto
                          ? GestureDetector(
                              onTap: () => showFullscreenImage(context, log.photoBase64!),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.memory(
                                  base64Decode(log.photoBase64!),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : const Icon(Icons.description),
                      title: Text(log.description),
                      subtitle: Text(
                        '${log.userName} • ${log.date} • ${log.percentComplete}% complete',
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
