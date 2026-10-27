import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progress_log.dart';

class ProgressLogService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('progress_logs');

  Future<void> addLog({
    required String projectId,
    required String userId,
    required String userName,
    required String date,
    required String description,
    required int percentComplete,
    String? photoBase64,
  }) {
    return _collection.add({
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'date': date,
      'description': description,
      'percentComplete': percentComplete,
      'photoBase64': photoBase64,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sorted client-side so this doesn't require a composite Firestore index
  /// for the userId equality + createdAt ordering combination. A log that
  /// was just written and hasn't received its server timestamp yet sorts to
  /// the top, so it appears immediately after being added.
  Stream<List<ProgressLog>> streamUserLogs(String userId) {
    return _collection.where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      final logs = snapshot.docs.map(ProgressLog.fromDoc).toList();
      logs.sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
      return logs;
    });
  }

  Stream<List<ProgressLog>> streamAllLogs() {
    return _collection.snapshots().map((snapshot) {
      final logs = snapshot.docs.map(ProgressLog.fromDoc).toList();
      logs.sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
      return logs;
    });
  }

  int _compareNewestFirst(Timestamp? a, Timestamp? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return b.compareTo(a);
  }
}
