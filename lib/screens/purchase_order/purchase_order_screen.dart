import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../models/purchase_order.dart';
import '../../services/material_request_service.dart';
import '../../services/notification_service.dart';
import '../../services/project_service.dart';
import '../../services/purchase_order_service.dart';
import '../widgets/base64_thumbnail.dart';
import '../widgets/empty_state.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../widgets/pay_now_button.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/status_chip.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  final _projectService = ProjectService();
  final _poService = PurchaseOrderService();
  final _materialRequestService = MaterialRequestService();
  final _notificationService = NotificationService();

  Project? _selectedProject;

  Future<void> _markDispatched(PurchaseOrder po) async {
    await _poService.updateStatus(po.id, 'dispatched');
    final request = await _materialRequestService.getRequest(po.materialRequestId);
    if (request == null) return;
    final recipients = <String>{request.raisedByUid};
    if (request.approvedByUid != null) recipients.add(request.approvedByUid!);
    await _notificationService.sendToMany(
      recipientUids: recipients.toList(),
      type: 'po_dispatched',
      title: 'Purchase order dispatched',
      body: '${po.itemName} × ${po.quantity} ${po.unit} was dispatched by ${po.vendorName}.',
      projectId: po.projectId,
      relatedCollection: 'purchase_orders',
      relatedDocId: po.id,
    );
  }

  Future<void> _showSubmitInvoiceDialog(BuildContext context, PurchaseOrder po) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _InvoiceDialog(
          onSubmit: (amount, photoBytes) async {
            await _poService.submitInvoice(
              poId: po.id,
              invoiceBase64: base64Encode(photoBytes),
              invoiceAmount: amount,
            );
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  Widget _statusAction(PurchaseOrder po) {
    switch (po.status) {
      case 'pending':
        return TextButton(
          onPressed: () => _markDispatched(po),
          child: const Text('Mark Dispatched'),
        );
      case 'dispatched':
        return TextButton(
          onPressed: () => _poService.updateStatus(po.id, 'delivered'),
          child: const Text('Mark Delivered'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.isVendor) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Orders')),
        body: StreamBuilder<List<PurchaseOrder>>(
          stream: _poService.streamForVendor(widget.user.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SkeletonList();
            }
            final orders = snapshot.data!;
            if (orders.isEmpty) {
              return const EmptyState(
                icon: Icons.local_shipping_outlined,
                message: 'No purchase orders assigned yet',
              );
            }
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final po = orders[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: po.hasInvoice
                              ? GestureDetector(
                                  onTap: () => showFullscreenImage(context, po.invoiceBase64!),
                                  child: Base64Thumbnail(base64String: po.invoiceBase64!),
                                )
                              : null,
                          title: Text('${po.itemName} × ${po.quantity} ${po.unit}'),
                          subtitle: Align(
                            alignment: Alignment.centerLeft,
                            child: StatusChip(status: po.status),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              _statusAction(po),
                              if (po.status == 'delivered' && !po.hasInvoice)
                                TextButton(
                                  onPressed: () => _showSubmitInvoiceDialog(context, po),
                                  child: const Text('Submit Invoice'),
                                ),
                              if (po.hasInvoice)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    'Invoice: ₹${po.invoiceAmount?.toStringAsFixed(2)}',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Orders')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectPickerField(
            projectsStream: _projectService.streamProjectsForUser(widget.user),
            onChanged: (project) => setState(() => _selectedProject = project),
          ),
          if (_selectedProject != null)
            Expanded(
              child: StreamBuilder<List<PurchaseOrder>>(
                stream: _poService.streamForProject(_selectedProject!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonList();
                  }
                  final orders = snapshot.data!;
                  if (orders.isEmpty) {
                    return const EmptyState(
                      icon: Icons.local_shipping_outlined,
                      message: 'No purchase orders yet',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final po = orders[index];
                      final canPay = widget.user.isPm &&
                          !po.isPaid &&
                          po.hasInvoice &&
                          (po.status == 'dispatched' || po.status == 'delivered');
                      return ListTile(
                        leading: po.hasInvoice
                            ? GestureDetector(
                                onTap: () => showFullscreenImage(context, po.invoiceBase64!),
                                child: Base64Thumbnail(base64String: po.invoiceBase64!),
                              )
                            : null,
                        title: Text('${po.itemName} × ${po.quantity} ${po.unit}'),
                        subtitle: Text(
                          po.hasInvoice
                              ? 'Vendor: ${po.vendorName} • Invoice: ₹${po.invoiceAmount?.toStringAsFixed(2)}'
                              : 'Vendor: ${po.vendorName}',
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusChip(status: po.status),
                            if (canPay) ...[
                              const SizedBox(height: 6),
                              PayNowButton(
                                amount: po.invoiceAmount!,
                                description: '${po.itemName} × ${po.quantity} ${po.unit} — ${po.vendorName}',
                                docRef: _poService.docRef(po.id),
                                payer: widget.user,
                              ),
                            ],
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

class _InvoiceDialog extends StatefulWidget {
  const _InvoiceDialog({required this.onSubmit});

  final Future<void> Function(double amount, Uint8List photoBytes) onSubmit;

  @override
  State<_InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<_InvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _imagePicker = ImagePicker();

  Uint8List? _photoBytes;
  bool _isSaving = false;

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _imagePicker.pickImage(source: source, maxWidth: 800, imageQuality: 70);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a photo of the invoice')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(double.parse(_amountController.text), _photoBytes!);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Invoice'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Invoice amount'),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
