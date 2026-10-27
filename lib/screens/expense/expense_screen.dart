import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/expense.dart';
import '../../models/project.dart';
import '../../services/expense_service.dart';
import '../../services/notification_service.dart';
import '../../services/project_service.dart';
import '../../services/user_service.dart';
import '../../utils/date_format.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/status_chip.dart';

const _categories = ['Materials', 'Labor', 'Transport', 'Equipment', 'Other'];

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _projectService = ProjectService();
  final _expenseService = ExpenseService();
  final _notificationService = NotificationService();
  final _userService = UserService();

  Project? _selectedProject;
  String? _categoryFilter;

  Future<void> _showAddExpenseDialog(BuildContext context, String projectId) async {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String category = _categories.first;
    DateTime date = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add Expense'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount'),
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => category = value);
                      },
                    ),
                    TextFormField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Note (optional)'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${formatDate(date)}'),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setDialogState(() => date = picked);
                          },
                          child: const Text('Change'),
                        ),
                      ],
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
                    final amount = double.parse(amountController.text);
                    await _expenseService.addExpense(
                      projectId: projectId,
                      userName: widget.user.name,
                      amount: amount,
                      category: category,
                      date: formatDate(date),
                      note: noteController.text.trim(),
                      enteredByUid: widget.user.uid,
                    );
                    final builderUids = await _userService.getUidsForRoles(['builder']);
                    await _notificationService.sendToMany(
                      recipientUids: builderUids,
                      type: 'expense_submitted',
                      title: 'New expense submitted',
                      body: '${widget.user.name} logged a $category expense of '
                          '₹${amount.toStringAsFixed(2)}.',
                      projectId: projectId,
                      relatedCollection: 'expenses',
                    );
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _decide(Expense expense, String status) async {
    await _expenseService.updateStatus(expense.id, status, widget.user.uid);
    await _notificationService.send(
      recipientUid: expense.enteredByUid,
      type: 'expense_$status',
      title: 'Expense $status',
      body: '${expense.category} • ₹${expense.amount.toStringAsFixed(2)} was $status.',
      projectId: expense.projectId,
      relatedCollection: 'expenses',
      relatedDocId: expense.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: (widget.user.isPm && _selectedProject != null)
          ? FloatingActionButton(
              onPressed: () => _showAddExpenseDialog(context, _selectedProject!.id),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String?>(
                initialValue: _categoryFilter,
                decoration: const InputDecoration(labelText: 'Filter by category'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All categories')),
                  for (final category in _categories)
                    DropdownMenuItem(value: category, child: Text(category)),
                ],
                onChanged: (value) => setState(() => _categoryFilter = value),
              ),
            ),
          if (_selectedProject != null)
            Expanded(
              child: StreamBuilder<List<Expense>>(
                stream: _expenseService.streamForProject(_selectedProject!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonList();
                  }
                  final expenses = snapshot.data!;
                  final visibleExpenses = _categoryFilter == null
                      ? expenses
                      : expenses.where((e) => e.category == _categoryFilter).toList();
                  final approvedTotal = expenses
                      .where((e) => e.status == 'approved')
                      .fold<double>(0, (sum, e) => sum + e.amount);
                  final pendingTotal = expenses
                      .where((e) => e.status == 'pending')
                      .fold<double>(0, (sum, e) => sum + e.amount);
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Budget: ₹${_selectedProject!.budget.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text('Approved: ₹${approvedTotal.toStringAsFixed(2)}'),
                                if (pendingTotal > 0)
                                  Text('Pending approval: ₹${pendingTotal.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: visibleExpenses.isEmpty
                            ? EmptyState(
                                icon: Icons.receipt_long_outlined,
                                message: expenses.isEmpty
                                    ? 'No expenses logged yet'
                                    : 'No expenses in this category',
                              )
                            : ListView.builder(
                                itemCount: visibleExpenses.length,
                                itemBuilder: (context, index) {
                                  final expense = visibleExpenses[index];
                                  return ListTile(
                                    title: Text(
                                      '${expense.category} • ₹${expense.amount.toStringAsFixed(2)}',
                                    ),
                                    subtitle: Text(
                                      [
                                        expense.date,
                                        expense.userName,
                                        if (expense.note.isNotEmpty) expense.note,
                                      ].join(' • '),
                                    ),
                                    trailing: (widget.user.isBuilder && expense.status == 'pending')
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                ),
                                                onPressed: () => _decide(expense, 'approved'),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.cancel, color: Colors.red),
                                                onPressed: () => _decide(expense, 'rejected'),
                                              ),
                                            ],
                                          )
                                        : StatusChip(status: expense.status),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
