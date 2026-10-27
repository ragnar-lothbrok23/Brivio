import 'package:cloud_firestore/cloud_firestore.dart';

class LaborAttendanceRecord {
  const LaborAttendanceRecord({
    required this.id,
    required this.projectId,
    required this.laborerId,
    required this.laborerName,
    required this.date,
    required this.status,
  });

  factory LaborAttendanceRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return LaborAttendanceRecord(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      laborerId: data['laborerId'] as String? ?? '',
      laborerName: data['laborerName'] as String? ?? '',
      date: data['date'] as String,
      status: data['status'] as String,
    );
  }

  final String id;
  final String projectId;
  final String laborerId;
  final String laborerName;
  final String date; // yyyy-MM-dd
  final String status; // 'Present' or 'Absent'

  bool get isPresent => status == 'Present';
}
