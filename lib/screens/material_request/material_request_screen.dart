import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/material_request.dart';
import '../../models/project.dart';
import '../../services/material_request_service.dart';
import '../../services/notification_service.dart';
import '../../services/project_service.dart';
import '../../services/purchase_order_service.dart';
import '../../services/user_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/status_chip.dart';

class MaterialRequestScreen extends StatefulWidget {
  const MaterialRequestScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<MaterialRequestScreen> createState() => _MaterialRequestScreenState();
}

class _MaterialRequestScreenState extends State<MaterialRequestScreen> {
  final _projectService = ProjectService();
  final _requestService = MaterialRequestService();
  final _purchaseOrderService = PurchaseOrderService();
  final _userService = UserService();
  final _notificationService = NotificationService();

  Project? _selectedProject;

  Future<void> _showRaiseRequestDialog(BuildContext context, String projectId) async {
    final formKey = GlobalKey<FormState>();
    final itemNameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Raise Material Request'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: itemNameController,
                    decoration: const InputDecoration(labelText: 'Item name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter an item name' : null,
                  ),
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) return 'Enter a valid quantity';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: 'Unit (e.g. bags, kg)'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter a unit' : null,
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
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
                await _requestService.createRequest(
                  projectId: projectId,
                  itemName: itemNameController.text.trim(),
                  quantity: int.parse(quantityController.text),
                  unit: unitController.text.trim(),
                  notes: notesController.text.trim(),
                  raisedByUid: widget.user.uid,
                  raisedByName: widget.user.name,
                );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Raise Request'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showApproveDialog(BuildContext context, MaterialRequest request) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Approve & Assign Vendor'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<AppUser>>(
              stream: _userService.streamUsersByRole('vendor'),
              builder: (context, snapshot) {
                final vendors = snapshot.data ?? const <AppUser>[];
                if (vendors.isEmpty) {
                  return const Text('No Vendor accounts exist yet');
                }
                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = vendors[index];
                      return ListTile(
                        title: Text(vendor.name),
                        subtitle: Text(vendor.email),
                        onTap: () async {
                          await _purchaseOrderService.createFromRequest(
                            request: request,
                            vendorUid: vendor.uid,
                            vendorName: vendor.name,
                          );
                          await _requestService.updateStatus(
                            request.id,
                            'approved',
                            widget.user.uid,
                          );
                          await _notificationService.send(
                            recipientUid: request.raisedByUid,
                            type: 'material_request_approved',
                            title: 'Material request approved',
                            body: '${request.itemName} × ${request.quantity} ${request.unit} '
                                'was approved and assigned to ${vendor.name}.',
                            projectId: request.projectId,
                            relatedCollection: 'material_requests',
                            relatedDocId: request.id,
                          );
                          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Requests')),
      floatingActionButton: (widget.user.isSiteEngineer && _selectedProject != null)
          ? FloatingActionButton(
              onPressed: () => _showRaiseRequestDialog(context, _selectedProject!.id),
              child: const Icon(Icons.add_shopping_cart),
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
            Expanded(
              child: StreamBuilder<List<MaterialRequest>>(
                stream: _requestService.streamForProject(_selectedProject!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonList();
                  }
                  final requests = snapshot.data!;
                  if (requests.isEmpty) {
                    return const EmptyState(
                      icon: Icons.add_shopping_cart_outlined,
                      message: 'No material requests yet',
                    );
                  }
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return ListTile(
                        title: Text('${request.itemName} × ${request.quantity} ${request.unit}'),
                        subtitle: Text(
                          request.notes.isEmpty
                              ? 'Raised by ${request.raisedByName}'
                              : 'Raised by ${request.raisedByName} • ${request.notes}',
                        ),
                        trailing: (widget.user.isPm && request.status == 'pending')
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                    onPressed: () => _showApproveDialog(context, request),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () async {
                                      await _requestService.updateStatus(
                                        request.id,
                                        'rejected',
                                        widget.user.uid,
                                      );
                                      await _notificationService.send(
                                        recipientUid: request.raisedByUid,
                                        type: 'material_request_rejected',
                                        title: 'Material request rejected',
                                        body: '${request.itemName} × ${request.quantity} '
                                            '${request.unit} was rejected.',
                                        projectId: request.projectId,
                                        relatedCollection: 'material_requests',
                                        relatedDocId: request.id,
                                      );
                                    },
                                  ),
                                ],
                              )
                            : StatusChip(status: request.status),
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
