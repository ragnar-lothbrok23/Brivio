import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/app_user.dart';
import '../../models/contractor_invoice.dart';
import '../../models/project.dart';
import '../../services/contractor_invoice_service.dart';
import '../../services/project_service.dart';
import '../widgets/base64_thumbnail.dart';
import '../widgets/empty_state.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../widgets/pay_now_button.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/status_chip.dart';

class ContractorInvoiceScreen extends StatefulWidget {
  const ContractorInvoiceScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ContractorInvoiceScreen> createState() => _ContractorInvoiceScreenState();
}

class _ContractorInvoiceScreenState extends State<ContractorInvoiceScreen> {
  final _projectService = ProjectService();
  final _invoiceService = ContractorInvoiceService();

  Project? _selectedProject;

  Future<void> _showSubmitDialog(BuildContext context, String projectId) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _SubmitInvoiceDialog(
          onSubmit: (amount, note, photoBytes) async {
            await _invoiceService.submitInvoice(
              projectId: projectId,
              contractorUid: widget.user.uid,
              contractorName: widget.user.name,
              amount: amount,
              invoiceBase64: base64Encode(photoBytes),
              note: note,
            );
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isContractor = widget.user.isContractor;
    final invoicesStream = isContractor
        ? _invoiceService.streamForContractor(widget.user.uid)
        : (_selectedProject == null
            ? const Stream<List<ContractorInvoice>>.empty()
            : _invoiceService.streamForProject(_selectedProject!.id));

    return Scaffold(
      appBar: AppBar(title: Text(isContractor ? 'My Invoices' : 'Contractor Invoices')),
      floatingActionButton: (isContractor && _selectedProject != null)
          ? FloatingActionButton(
              onPressed: () => _showSubmitDialog(context, _selectedProject!.id),
              child: const Icon(Icons.receipt_long),
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
              child: StreamBuilder<List<ContractorInvoice>>(
                stream: invoicesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonList();
                  }
                  final invoices = snapshot.data!;
                  if (invoices.isEmpty) {
                    return const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'No invoices submitted yet',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      final canPay = !isContractor &&
                          widget.user.isPm &&
                          invoice.status == 'submitted';
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () => showFullscreenImage(context, invoice.invoiceBase64),
                          child: Base64Thumbnail(base64String: invoice.invoiceBase64),
                        ),
                        title: Text('₹${invoice.amount.toStringAsFixed(2)}'),
                        subtitle: Text(
                          isContractor
                              ? invoice.note
                              : [invoice.contractorName, invoice.note]
                                  .where((s) => s.isNotEmpty)
                                  .join(' • '),
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusChip(status: invoice.status),
                            if (canPay) ...[
                              const SizedBox(height: 6),
                              PayNowButton(
                                amount: invoice.amount,
                                description: 'Invoice — ${invoice.contractorName}',
                                docRef: _invoiceService.docRef(invoice.id),
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

class _SubmitInvoiceDialog extends StatefulWidget {
  const _SubmitInvoiceDialog({required this.onSubmit});

  final Future<void> Function(double amount, String note, Uint8List photoBytes) onSubmit;

  @override
  State<_SubmitInvoiceDialog> createState() => _SubmitInvoiceDialogState();
}

class _SubmitInvoiceDialogState extends State<_SubmitInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
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
      await widget.onSubmit(
        double.parse(_amountController.text),
        _noteController.text.trim(),
        _photoBytes!,
      );
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
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
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
