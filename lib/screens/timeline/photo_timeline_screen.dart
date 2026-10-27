import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/progress_log.dart';
import '../../models/project.dart';
import '../../services/progress_log_service.dart';
import '../../services/project_service.dart';
import '../widgets/base64_thumbnail.dart';
import '../widgets/empty_state.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';

class PhotoTimelineScreen extends StatefulWidget {
  const PhotoTimelineScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<PhotoTimelineScreen> createState() => _PhotoTimelineScreenState();
}

class _PhotoTimelineScreenState extends State<PhotoTimelineScreen> {
  final _projectService = ProjectService();
  final _progressLogService = ProgressLogService();

  Project? _selectedProject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Timeline')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectPickerField(
            projectsStream: _projectService.streamProjectsForUser(widget.user),
            onChanged: (project) => setState(() => _selectedProject = project),
          ),
          if (_selectedProject != null)
            Expanded(
              child: StreamBuilder<List<ProgressLog>>(
                stream: _progressLogService.streamAllLogs(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonList();
                  }
                  final photos = snapshot.data!
                      .where((log) => log.projectId == _selectedProject!.id && log.hasPhoto)
                      .toList()
                    ..sort((a, b) => a.date.compareTo(b.date));
                  if (photos.isEmpty) {
                    return const EmptyState(
                      icon: Icons.photo_library_outlined,
                      message: 'No progress photos yet for this project',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final log = photos[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => showFullscreenImage(context, log.photoBase64!),
                              child: Base64Thumbnail.rect(
                                base64String: log.photoBase64!,
                                width: double.infinity,
                                height: 220,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${log.date} • ${log.userName}',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${log.percentComplete}% complete'),
                                  if (log.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(log.description),
                                    ),
                                ],
                              ),
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
  }
}
