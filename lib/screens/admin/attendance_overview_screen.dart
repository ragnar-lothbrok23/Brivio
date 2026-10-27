import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/labor_attendance_record.dart';
import '../../models/laborer.dart';
import '../../models/project.dart';
import '../../models/staff_check_in.dart';
import '../../services/labor_attendance_service.dart';
import '../../services/laborer_service.dart';
import '../../services/project_service.dart';
import '../../services/staff_attendance_service.dart';
import '../../utils/date_format.dart';

class AttendanceOverviewScreen extends StatefulWidget {
  const AttendanceOverviewScreen({super.key});

  @override
  State<AttendanceOverviewScreen> createState() => _AttendanceOverviewScreenState();
}

class _AttendanceOverviewScreenState extends State<AttendanceOverviewScreen> {
  final _projectService = ProjectService();
  final _laborerService = LaborerService();
  final _laborAttendanceService = LaborAttendanceService();
  final _staffAttendanceService = StaffAttendanceService();
  late final String _today = formatDate(DateTime.now());

  String? _selectedProjectId;

  String _formatTime(Timestamp? timestamp) {
    final time = timestamp?.toDate();
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Overview')),
      body: StreamBuilder<List<Project>>(
        stream: _projectService.streamAllProjects(),
        builder: (context, projectsSnapshot) {
          final allProjects = projectsSnapshot.data ?? const <Project>[];
          final visibleProjects = _selectedProjectId == null
              ? allProjects
              : allProjects.where((p) => p.id == _selectedProjectId).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String?>(
                initialValue: _selectedProjectId,
                decoration: const InputDecoration(labelText: 'Project'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Projects')),
                  for (final project in allProjects)
                    DropdownMenuItem(value: project.id, child: Text(project.name)),
                ],
                onChanged: (value) => setState(() => _selectedProjectId = value),
              ),
              const SizedBox(height: 24),
              Text('Labor Headcount', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (visibleProjects.isEmpty)
                const Text('No projects yet')
              else
                StreamBuilder<List<LaborAttendanceRecord>>(
                  stream: _laborAttendanceService.streamForDate(_today),
                  builder: (context, attendanceSnapshot) {
                    final presentByProject = <String, int>{};
                    for (final record
                        in attendanceSnapshot.data ?? const <LaborAttendanceRecord>[]) {
                      if (record.isPresent) {
                        presentByProject[record.projectId] =
                            (presentByProject[record.projectId] ?? 0) + 1;
                      }
                    }
                    return Column(
                      children: [
                        for (final project in visibleProjects)
                          StreamBuilder<List<Laborer>>(
                            stream: _laborerService.streamLaborers(project.id),
                            builder: (context, laborersSnapshot) {
                              final total = laborersSnapshot.data?.length ?? 0;
                              final present = presentByProject[project.id] ?? 0;
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.groups),
                                  title: Text(project.name),
                                  trailing: Text('$present/$total present'),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 24),
              Text('Staff Check-in', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              StreamBuilder<List<StaffCheckIn>>(
                stream: _staffAttendanceService.streamForDate(_today),
                builder: (context, snapshot) {
                  final checkIns = (snapshot.data ?? const <StaffCheckIn>[])
                      .where((c) => _selectedProjectId == null || c.projectId == _selectedProjectId)
                      .toList();
                  if (checkIns.isEmpty) {
                    return const Text('No staff checked in yet today');
                  }
                  return Column(
                    children: [
                      for (final checkIn in checkIns)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(checkIn.userName),
                            subtitle: Text(kRoleLabels[checkIn.role] ?? checkIn.role),
                            trailing: Text(_formatTime(checkIn.checkedInAt)),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
