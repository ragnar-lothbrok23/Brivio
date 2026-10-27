import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../services/expense_service.dart';
import '../../services/progress_log_service.dart';
import '../../services/project_service.dart';
import '../widgets/project_picker_field.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _projectService = ProjectService();
  final _expenseService = ExpenseService();
  final _progressLogService = ProgressLogService();

  Project? _selectedProject;
  bool _isGenerating = false;

  Future<void> _generateAndShare() async {
    final project = _selectedProject;
    if (project == null) return;

    setState(() => _isGenerating = true);
    try {
      final expenses = await _expenseService.streamForProject(project.id).first;
      final allLogs = await _progressLogService.streamAllLogs().first;
      final logs = allLogs.where((log) => log.projectId == project.id).toList();

      final approved = expenses.where((e) => e.status == 'approved').toList();
      final approvedTotal = approved.fold<double>(0, (sum, e) => sum + e.amount);
      final pendingTotal = expenses
          .where((e) => e.status == 'pending')
          .fold<double>(0, (sum, e) => sum + e.amount);
      final averageProgress = logs.isEmpty
          ? 0.0
          : logs.map((l) => l.percentComplete).reduce((a, b) => a + b) / logs.length;

      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, text: 'Brivio Project Report'),
            pw.SizedBox(height: 8),
            pw.Text(
              project.name,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Client: ${project.client}'),
            pw.SizedBox(height: 16),
            pw.Text('Budget vs Cost', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: 'Budget: Rs ${project.budget.toStringAsFixed(2)}'),
            pw.Bullet(text: 'Approved expenses: Rs ${approvedTotal.toStringAsFixed(2)}'),
            pw.Bullet(text: 'Pending approval: Rs ${pendingTotal.toStringAsFixed(2)}'),
            pw.Bullet(
              text: 'Remaining budget: Rs ${(project.budget - approvedTotal).toStringAsFixed(2)}',
            ),
            pw.SizedBox(height: 16),
            pw.Text('Progress', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Bullet(
              text: 'Average progress: ${averageProgress.toStringAsFixed(1)}% '
                  '(${logs.length} log entries)',
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Approved Expenses',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            if (approved.isEmpty)
              pw.Text('No approved expenses yet')
            else
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Date', 'Category', 'Amount', 'Note'],
                data: [
                  for (final e in approved)
                    [e.date, e.category, 'Rs ${e.amount.toStringAsFixed(2)}', e.note],
                ],
              ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
        name: 'Brivio_${project.name}_Report.pdf',
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Report')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectPickerField(
            projectsStream: _projectService.streamProjectsForUser(widget.user),
            onChanged: (project) => setState(() => _selectedProject = project),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isGenerating
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _selectedProject == null ? null : _generateAndShare,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate PDF Report'),
                  ),
          ),
        ],
      ),
    );
  }
}
