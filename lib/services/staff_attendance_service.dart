import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/staff_check_in.dart';

class StaffAttendanceService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('staff_attendance');

  String _docId(String projectId, String userId, String date) => '${projectId}_${userId}_$date';

  Future<void> checkIn({
    required String projectId,
    required String userId,
    required String userName,
    required String role,
    required String date,
  }) {
    return _collection.doc(_docId(projectId, userId, date)).set({
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'role': role,
      'date': date,
      'checkedInAt': FieldValue.serverTimestamp(),
    });
  }

  Future<StaffCheckIn?> getCheckInForToday(String projectId, String userId, String date) async {
    final doc = await _collection.doc(_docId(projectId, userId, date)).get();
    if (!doc.exists) return null;
    return StaffCheckIn.fromDoc(doc);
  }

  /// Single `.where()` on date only, same reasoning as
  /// `LaborAttendanceService.streamForDate` — the overview groups/filters by
  /// project client-side.
  Stream<List<StaffCheckIn>> streamForDate(String date) {
    return _collection
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(StaffCheckIn.fromDoc).toList());
  }
}
