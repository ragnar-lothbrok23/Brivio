import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/inventory_item.dart';
import '../../models/project.dart';
import '../../services/inventory_service.dart';
import '../../services/project_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _projectService = ProjectService();
  final _inventoryService = InventoryService();
  final _searchController = TextEditingController();

  Project? _selectedProject;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddItemDialog(BuildContext context, String projectId) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Material'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Material name'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Enter a name' : null,
                ),
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed < 0) return 'Enter a valid quantity';
                    return null;
                  },
                ),
                TextFormField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Unit (e.g. bags, kg)'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Enter a unit' : null,
                ),
              ],
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
                await _inventoryService.addItem(
                  projectId: projectId,
                  name: nameController.text.trim(),
                  quantity: int.parse(quantityController.text),
                  unit: unitController.text.trim(),
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

  bool get _canEdit => widget.user.isBuilder || widget.user.isPm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Inventory')),
      floatingActionButton: (_canEdit && _selectedProject != null)
          ? FloatingActionButton(
              onPressed: () => _showAddItemDialog(context, _selectedProject!.id),
              child: const Icon(Icons.add),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search materials',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
              ),
            ),
          if (_selectedProject != null)
            Expanded(
              child: StreamBuilder<List<InventoryItem>>(
                stream: _inventoryService.streamForProject(_selectedProject!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonList();
                  }
                  final items = snapshot.data!
                      .where((item) => item.name.toLowerCase().contains(_searchQuery))
                      .toList();
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: _searchQuery.isEmpty
                          ? 'No materials added yet'
                          : 'No materials match "$_searchQuery"',
                    );
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.quantity} ${item.unit}'),
                        trailing: !_canEdit
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: item.quantity <= 0
                                        ? null
                                        : () => _inventoryService.adjustQuantity(item.id, -1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _inventoryService.adjustQuantity(item.id, 1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _inventoryService.deleteItem(item.id),
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
