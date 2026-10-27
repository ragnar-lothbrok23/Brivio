import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressLog {
  const ProgressLog({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    required this.date,
    required this.description,
    required this.percentComplete,
    required this.createdAt,
    this.photoBase64,
  });

  factory ProgressLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProgressLog(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      userId: data['userId'] as String,
      userName: data['userName'] as String? ?? '',
      date: data['date'] as String,
      description: data['description'] as String? ?? '',
      percentComplete: data['percentComplete'] as int? ?? 0,
      createdAt: data['createdAt'] as Timestamp?,
      photoBase64: data['photoBase64'] as String?,
    );
  }

  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final String date; // yyyy-MM-dd
  final String description;
  final int percentComplete;
  final Timestamp? createdAt;
  final String? photoBase64;

  bool get hasPhoto => photoBase64 != null && photoBase64!.isNotEmpty;
}
