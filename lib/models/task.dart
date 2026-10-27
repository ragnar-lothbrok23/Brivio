import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_format.dart';

/// Maps status id -> display label, in the order they should appear in
/// filter chips.
const Map<String, String> kTaskStatusLabels = {
  'assigned': 'Assigned',
  'in_progress': 'In Progress',
  'completed': 'Completed',
};

class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.assignedToUid,
    required this.assignedToName,
    required this.status,
    required this.createdAt,
    this.dueDate,
  });

  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      assignedToUid: data['assignedToUid'] as String? ?? '',
      assignedToName: data['assignedToName'] as String? ?? '',
      status: data['status'] as String? ?? 'assigned',
      createdAt: data['createdAt'] as Timestamp?,
      dueDate: data['dueDate'] as String?,
    );
  }

  final String id;
  final String projectId;
  final String title;
  final String description;
  final String assignedToUid;
  final String assignedToName;
  final String status; // 'assigned' | 'in_progress' | 'completed'
  final Timestamp? createdAt;
  final String? dueDate; // yyyy-MM-dd

  bool get isOverdue {
    if (dueDate == null || status == 'completed') return false;
    return dueDate!.compareTo(formatDate(DateTime.now())) < 0;
  }
}
