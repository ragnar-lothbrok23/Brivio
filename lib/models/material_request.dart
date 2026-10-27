import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialRequest {
  const MaterialRequest({
    required this.id,
    required this.projectId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.notes,
    required this.raisedByUid,
    required this.raisedByName,
    required this.status,
    required this.createdAt,
    this.approvedByUid,
    this.approvedAt,
  });

  factory MaterialRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MaterialRequest(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      itemName: data['itemName'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unit: data['unit'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      raisedByUid: data['raisedByUid'] as String? ?? '',
      raisedByName: data['raisedByName'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: data['createdAt'] as Timestamp?,
      approvedByUid: data['approvedByUid'] as String?,
      approvedAt: data['approvedAt'] as Timestamp?,
    );
  }

  final String id;
  final String projectId;
  final String itemName;
  final int quantity;
  final String unit;
  final String notes;
  final String raisedByUid;
  final String raisedByName;
  final String status; // 'pending' | 'approved' | 'rejected'
  final Timestamp? createdAt;
  final String? approvedByUid;
  final Timestamp? approvedAt;
}
