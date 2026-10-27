import 'package:cloud_firestore/cloud_firestore.dart';

class StaffCheckIn {
  const StaffCheckIn({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    required this.role,
    required this.date,
    required this.checkedInAt,
  });

  factory StaffCheckIn.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return StaffCheckIn(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      userId: data['userId'] as String,
      userName: data['userName'] as String? ?? '',
      role: data['role'] as String? ?? '',
      date: data['date'] as String,
      checkedInAt: data['checkedInAt'] as Timestamp?,
    );
  }

  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final String role;
  final String date; // yyyy-MM-dd
  final Timestamp? checkedInAt;
}
