import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/app_user.dart';
import '../../models/progress_log.dart';
import '../../models/project.dart';
import '../../services/progress_log_service.dart';
import '../../services/project_service.dart';
import '../../utils/date_format.dart';
import '../widgets/empty_state.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/weather_card.dart';

class ProgressLogScreen extends StatefulWidget {
  const ProgressLogScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ProgressLogScreen> createState() => _ProgressLogScreenState();
}

class _ProgressLogScreenState extends State<ProgressLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _progressLogService = ProgressLogService();
  final _projectService = ProjectService();
  final _imagePicker = ImagePicker();

  Project? _selectedProject;
  double _percentComplete = 0;
  Uint8List? _photoBytes;
  bool _isSaving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 70,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProject == null) return;
    setState(() => _isSaving = true);
    try {
      await _progressLogService.addLog(
        projectId: _selectedProject!.id,
        userId: widget.user.uid,
        userName: widget.user.name,
        date: formatDate(DateTime.now()),
        description: _descriptionController.text.trim(),
        percentComplete: _percentComplete.round(),
        photoBase64: _photoBytes == null ? null : base64Encode(_photoBytes!),
      );
      _descriptionController.clear();
      setState(() {
        _percentComplete = 0;
        _photoBytes = null;
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Progress Log')),
      body: Column(
        children: [
          ProjectPickerField(
            projectsStream: _projectService.streamProjectsForUser(widget.user),
            onChanged: (project) => setState(() => _selectedProject = project),
          ),
          if (_selectedProject != null) WeatherCard(project: _selectedProject!),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Today's work",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Describe the work done today'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text('% Complete: ${_percentComplete.round()}'),
                  Slider(
                    value: _percentComplete,
                    max: 100,
                    divisions: 20,
                    label: '${_percentComplete.round()}%',
                    onChanged: (value) => setState(() => _percentComplete = value),
                  ),
                  if (_photoBytes != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Image.memory(_photoBytes!, height: 120),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isSaving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _selectedProject == null ? null : _submit,
                          child: const Text('Save Entry'),
                        ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('History', style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: StreamBuilder<List<ProgressLog>>(
              stream: _progressLogService.streamUserLogs(widget.user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SkeletonList();
                }
                final logs = snapshot.data!;
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
                      subtitle: Text('${log.date} • ${log.percentComplete}% complete'),
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
