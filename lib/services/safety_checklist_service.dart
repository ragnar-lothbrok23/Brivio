import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/safety_checklist.dart';

class SafetyChecklistService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('safety_checklists');

  Future<void> submitChecklist({
    required String projectId,
    required String conductedByUid,
    required String conductedByName,
    required String date,
    required List<SafetyChecklistItem> items,
    required String notes,
  }) {
    return _collection.add({
      'projectId': projectId,
      'conductedByUid': conductedByUid,
      'conductedByName': conductedByName,
      'date': date,
      'items': items.map((item) => item.toMap()).toList(),
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sorted client-side so this doesn't require a composite Firestore index
  /// for the projectId equality + createdAt ordering combination.
  Stream<List<SafetyChecklist>> streamForProject(String projectId) {
    return _collection.where('projectId', isEqualTo: projectId).snapshots().map((snapshot) {
      final checklists = snapshot.docs.map(SafetyChecklist.fromDoc).toList();
      checklists.sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
      return checklists;
    });
  }

  int _compareNewestFirst(Timestamp? a, Timestamp? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return b.compareTo(a);
  }
}
