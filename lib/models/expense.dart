import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  const Expense({
    required this.id,
    required this.projectId,
    required this.userName,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    required this.enteredByUid,
    required this.status,
    this.approvedByUid,
    this.approvedAt,
  });

  factory Expense.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Expense(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String? ?? 'Other',
      date: data['date'] as String,
      note: data['note'] as String? ?? '',
      enteredByUid: data['enteredByUid'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      approvedByUid: data['approvedByUid'] as String?,
      approvedAt: data['approvedAt'] as Timestamp?,
    );
  }

  final String id;
  final String projectId;
  final String userName;
  final double amount;
  final String category;
  final String date; // yyyy-MM-dd
  final String note;
  final String enteredByUid;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? approvedByUid;
  final Timestamp? approvedAt;
}
