import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/tappable_card.dart';
import 'project_detail_screen.dart';

class ProjectScreen extends StatelessWidget {
  ProjectScreen({super.key, required this.currentUserUid});

  final String currentUserUid;
  final _projectService = ProjectService();

  Future<void> _showAddProjectDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final clientController = TextEditingController();
    final budgetController = TextEditingController();
    final locationController = TextEditingController();
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('New Project'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Project name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Enter a name' : null,
                    ),
                    TextFormField(
                      controller: clientController,
                      decoration: const InputDecoration(labelText: 'Client'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Enter a client' : null,
                    ),
                    TextFormField(
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Budget'),
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed < 0) return 'Enter a valid budget';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (city, optional)',
                        helperText: 'Used to show weather on the Progress Log screen',
                      ),
                    ),
                  ],
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
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSaving = true);
                          await _projectService.createProject(
                            name: nameController.text.trim(),
                            client: clientController.text.trim(),
                            budget: double.parse(budgetController.text),
                            createdByUid: currentUserUid,
                            location: locationController.text.trim(),
                          );
                          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
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
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Project>>(
        stream: _projectService.streamAllProjects(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SkeletonList();
          }
          final projects = snapshot.data!;
          if (projects.isEmpty) {
            return const EmptyState(
              icon: Icons.apartment_outlined,
              message: 'No projects yet',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return TappableCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
                  );
                },
                child: ListTile(
                  leading: const Icon(Icons.apartment),
                  title: Text(project.name),
                  subtitle: Text('${project.client} · Budget ₹${project.budget.toStringAsFixed(0)}'),
                  trailing: Text(project.status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
