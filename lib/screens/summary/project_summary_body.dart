import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/contractor_invoice.dart';
import '../../models/expense.dart';
import '../../models/labor_attendance_record.dart';
import '../../models/progress_log.dart';
import '../../models/project.dart';
import '../../models/purchase_order.dart';
import '../../services/contractor_invoice_service.dart';
import '../../services/expense_service.dart';
import '../../services/labor_attendance_service.dart';
import '../../services/progress_log_service.dart';
import '../../services/project_service.dart';
import '../../services/purchase_order_service.dart';
import '../widgets/animated_counter.dart';
import '../widgets/project_picker_field.dart';

const _categoryColors = [
  Colors.indigo,
  Colors.teal,
  Colors.orange,
  Colors.purple,
  Colors.brown,
];

/// Project picker + stat cards + charts — the actual content of the
/// "Project Summary" feature, factored out of its own screen so it can
/// also be embedded inline on a dashboard. Doesn't scroll itself; the
/// caller decides the scrolling container.
class ProjectSummaryBody extends StatefulWidget {
  const ProjectSummaryBody({super.key, required this.user});

  final AppUser user;

  @override
  State<ProjectSummaryBody> createState() => _ProjectSummaryBodyState();
}

class _ProjectSummaryBodyState extends State<ProjectSummaryBody> {
  final _projectService = ProjectService();
  final _laborAttendanceService = LaborAttendanceService();
  final _expenseService = ExpenseService();
  final _progressLogService = ProgressLogService();
  final _poService = PurchaseOrderService();
  final _invoiceService = ContractorInvoiceService();

  Project? _selectedProject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectPickerField(
          projectsStream: _projectService.streamProjectsForUser(widget.user),
          onChanged: (project) => setState(() => _selectedProject = project),
        ),
        if (_selectedProject != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<List<LaborAttendanceRecord>>(
                  stream: _laborAttendanceService.streamForProject(_selectedProject!.id),
                  builder: (context, snapshot) {
                    final records = snapshot.data ?? [];
                    final presentCount = records.where((r) => r.isPresent).length;
                    final percent = records.isEmpty ? 0.0 : presentCount / records.length * 100;
                    return _SummaryCard(
                      icon: Icons.event_available,
                      title: 'Labor Attendance',
                      value: percent,
                      valueFormatter: (v) => '${v.toStringAsFixed(1)}%',
                      subtitle: '$presentCount present out of ${records.length} records',
                    );
                  },
                ),
                StreamBuilder<List<ProgressLog>>(
                  stream: _progressLogService.streamAllLogs(),
                  builder: (context, snapshot) {
                    final logs = (snapshot.data ?? [])
                        .where((log) => log.projectId == _selectedProject!.id)
                        .toList()
                      ..sort((a, b) => a.date.compareTo(b.date));
                    final averagePercent = logs.isEmpty
                        ? 0.0
                        : logs.map((l) => l.percentComplete).reduce((a, b) => a + b) /
                            logs.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryCard(
                          icon: Icons.assignment,
                          title: 'Average Progress',
                          value: averagePercent,
                          valueFormatter: (v) => '${v.toStringAsFixed(1)}%',
                          subtitle: '${logs.length} progress log entries',
                        ),
                        if (logs.length >= 2) ...[
                          const SizedBox(height: 8),
                          Text('Progress over time', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          SizedBox(height: 180, child: _ProgressChart(logs: logs)),
                          const SizedBox(height: 16),
                        ],
                      ],
                    );
                  },
                ),
                StreamBuilder<List<Expense>>(
                  stream: _expenseService.streamForProject(_selectedProject!.id),
                  builder: (context, snapshot) {
                    final approved =
                        (snapshot.data ?? []).where((e) => e.status == 'approved').toList();
                    final total = approved.fold<double>(0, (sum, e) => sum + e.amount);
                    final byCategory = <String, double>{};
                    for (final expense in approved) {
                      byCategory[expense.category] =
                          (byCategory[expense.category] ?? 0) + expense.amount;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryCard(
                          icon: Icons.currency_rupee,
                          title: 'Total Expenses',
                          value: total,
                          valueFormatter: (v) => '₹${v.toStringAsFixed(2)}',
                          subtitle: '${approved.length} approved expense entries',
                        ),
                        if (byCategory.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Expenses by category',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(height: 200, child: _ExpensePieChart(byCategory: byCategory)),
                        ],
                      ],
                    );
                  },
                ),
                StreamBuilder<List<PurchaseOrder>>(
                  stream: _poService.streamForProject(_selectedProject!.id),
                  builder: (context, poSnapshot) {
                    return StreamBuilder<List<ContractorInvoice>>(
                      stream: _invoiceService.streamForProject(_selectedProject!.id),
                      builder: (context, invoiceSnapshot) {
                        final paidOrders =
                            (poSnapshot.data ?? []).where((po) => po.isPaid).toList();
                        final paidInvoices = (invoiceSnapshot.data ?? [])
                            .where((invoice) => invoice.isPaid)
                            .toList();
                        final total = paidOrders.fold<double>(
                              0,
                              (sum, po) => sum + (po.invoiceAmount ?? 0),
                            ) +
                            paidInvoices.fold<double>(0, (sum, invoice) => sum + invoice.amount);
                        return _SummaryCard(
                          icon: Icons.payments,
                          title: 'Vendor & Contractor Payments',
                          value: total,
                          valueFormatter: (v) => '₹${v.toStringAsFixed(2)}',
                          subtitle:
                              '${paidOrders.length} paid POs • ${paidInvoices.length} paid invoices',
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ProgressChart extends StatelessWidget {
  const _ProgressChart({required this.logs});

  final List<ProgressLog> logs;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= logs.length) return const SizedBox.shrink();
                final date = logs[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    date.length >= 5 ? date.substring(5) : date,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < logs.length; i++)
                FlSpot(i.toDouble(), logs[i].percentComplete.toDouble()),
            ],
            isCurved: true,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class _ExpensePieChart extends StatelessWidget {
  const _ExpensePieChart({required this.byCategory});

  final Map<String, double> byCategory;

  @override
  Widget build(BuildContext context) {
    final entries = byCategory.entries.toList();
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: [
                for (int i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    title: '',
                    color: _categoryColors[i % _categoryColors.length],
                    radius: 60,
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: _categoryColors[i % _categoryColors.length],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${entries[i].key}: ₹${entries[i].value.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.valueFormatter,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final double value;
  final String Function(double value) valueFormatter;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            AnimatedCounter(
              value: value,
              formatter: valueFormatter,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
