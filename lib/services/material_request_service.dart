import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/material_request.dart';

class MaterialRequestService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('material_requests');

  Future<void> createRequest({
    required String projectId,
    required String itemName,
    required int quantity,
    required String unit,
    required String notes,
    required String raisedByUid,
    required String raisedByName,
  }) {
    return _collection.add({
      'projectId': projectId,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'raisedByUid': raisedByUid,
      'raisedByName': raisedByName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String requestId, String status, String decidedByUid) {
    return _collection.doc(requestId).update({
      'status': status,
      'approvedByUid': decidedByUid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<MaterialRequest?> getRequest(String requestId) async {
    final doc = await _collection.doc(requestId).get();
    if (!doc.exists) return null;
    return MaterialRequest.fromDoc(doc);
  }

  /// Sorted client-side so this doesn't require a composite Firestore index
  /// for the projectId equality + createdAt ordering combination.
  Stream<List<MaterialRequest>> streamForProject(String projectId) {
    return _collection.where('projectId', isEqualTo: projectId).snapshots().map((snapshot) {
      final requests = snapshot.docs.map(MaterialRequest.fromDoc).toList();
      requests.sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
      return requests;
    });
  }

  int _compareNewestFirst(Timestamp? a, Timestamp? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return b.compareTo(a);
  }
}
