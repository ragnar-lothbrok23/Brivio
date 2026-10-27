import 'package:flutter/material.dart';

import '../../models/project.dart';

/// A dropdown that lets the user pick one project out of [projectsStream],
/// notifying [onChanged] both on user interaction and once automatically
/// when the list first loads (so callers get a sensible default without the
/// user having to touch the dropdown for the single-project case).
class ProjectPickerField extends StatefulWidget {
  const ProjectPickerField({
    super.key,
    required this.projectsStream,
    required this.onChanged,
  });

  final Stream<List<Project>> projectsStream;
  final ValueChanged<Project?> onChanged;

  @override
  State<ProjectPickerField> createState() => _ProjectPickerFieldState();
}

class _ProjectPickerFieldState extends State<ProjectPickerField> {
  String? _selectedId;
  bool _notifiedEmpty = false;
  Project? _lastNotified;

  /// StreamBuilder's `builder` re-runs on every rebuild of this widget (not
  /// only when the stream actually emits), so notifying unconditionally
  /// here would call `widget.onChanged` every build — and since the caller
  /// typically calls `setState` in response, that's an infinite rebuild
  /// loop. Only notify when the resolved project's data actually changed.
  bool _sameProject(Project a, Project? b) {
    if (b == null || a.id != b.id) return false;
    if (a.name != b.name || a.client != b.client || a.budget != b.budget || a.status != b.status) {
      return false;
    }
    if (a.location != b.location || a.latitude != b.latitude || a.longitude != b.longitude) {
      return false;
    }
    if (a.contractorScopes.length != b.contractorScopes.length) return false;
    for (final entry in a.contractorScopes.entries) {
      if (b.contractorScopes[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Project>>(
      stream: widget.projectsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          );
        }

        final projects = snapshot.data!;
        if (projects.isEmpty) {
          if (!_notifiedEmpty) {
            _notifiedEmpty = true;
            _lastNotified = null;
            WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged(null));
          }
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No project assigned yet — contact your PM or Builder.'),
          );
        }
        _notifiedEmpty = false;

        // Re-resolve on every emission so an edit to the selected project's
        // own data (e.g. a budget or contractor scope change) is picked up
        // even though its id didn't change — but only re-notify the caller
        // when something actually changed, not on every rebuild.
        final matches = projects.where((p) => p.id == _selectedId);
        final selected = matches.isEmpty ? projects.first : matches.first;
        _selectedId = selected.id;
        if (!_sameProject(selected, _lastNotified)) {
          _lastNotified = selected;
          WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged(selected));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedId,
            decoration: const InputDecoration(labelText: 'Project'),
            items: [
              for (final project in projects)
                DropdownMenuItem(value: project.id, child: Text(project.name)),
            ],
            onChanged: (value) {
              final project = projects.firstWhere((p) => p.id == value);
              setState(() => _selectedId = value);
              widget.onChanged(project);
            },
          ),
        );
      },
    );
  }
}
