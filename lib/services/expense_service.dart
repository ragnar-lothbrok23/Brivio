import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

class ExpenseService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('expenses');

  Stream<List<Expense>> streamExpenses() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Expense.fromDoc).toList());
  }

  /// Single `.where()` on projectId only — sorted client-side, same
  /// composite-index reasoning as the rest of the app's services.
  Stream<List<Expense>> streamForProject(String projectId) {
    return _collection.where('projectId', isEqualTo: projectId).snapshots().map((snapshot) {
      final expenses = snapshot.docs.map(Expense.fromDoc).toList();
      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    });
  }

  Future<void> addExpense({
    required String projectId,
    required String userName,
    required double amount,
    required String category,
    required String date,
    required String note,
    required String enteredByUid,
  }) {
    return _collection.add({
      'projectId': projectId,
      'userName': userName,
      'amount': amount,
      'category': category,
      'date': date,
      'note': note,
      'enteredByUid': enteredByUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String expenseId, String status, String approvedByUid) {
    return _collection.doc(expenseId).update({
      'status': status,
      'approvedByUid': approvedByUid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }
}
