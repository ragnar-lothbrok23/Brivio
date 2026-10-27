import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/labor_attendance_record.dart';

class LaborAttendanceService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('laborer_attendance');

  String _docId(String projectId, String laborerId, String date) =>
      '${projectId}_${laborerId}_$date';

  Future<void> markAttendance({
    required String projectId,
    required String laborerId,
    required String laborerName,
    required String date,
    required String status,
  }) {
    return _collection.doc(_docId(projectId, laborerId, date)).set({
      'projectId': projectId,
      'laborerId': laborerId,
      'laborerName': laborerName,
      'date': date,
      'status': status,
      'markedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Single `.where()` on projectId only — date is filtered client-side so
  /// this doesn't need a composite index.
  Stream<List<LaborAttendanceRecord>> streamForProject(String projectId) {
    return _collection
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(LaborAttendanceRecord.fromDoc).toList());
  }

  /// Single `.where()` on date only — used by the overview to summarize
  /// headcount across every project at once without a composite/collection
  /// group index; the caller groups by projectId client-side.
  Stream<List<LaborAttendanceRecord>> streamForDate(String date) {
    return _collection
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(LaborAttendanceRecord.fromDoc).toList());
  }

  /// Every record, unfiltered — used by the project summary's overall
  /// attendance-percent card.
  Stream<List<LaborAttendanceRecord>> streamAll() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs.map(LaborAttendanceRecord.fromDoc).toList(),
        );
  }
}
