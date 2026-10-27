import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/laborer.dart';

class LaborerService {
  CollectionReference<Map<String, dynamic>> _collection(String projectId) => FirebaseFirestore
      .instance
      .collection('projects')
      .doc(projectId)
      .collection('laborers');

  Stream<List<Laborer>> streamLaborers(String projectId) {
    return _collection(projectId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Laborer.fromDoc).toList());
  }

  Future<void> addLaborer({
    required String projectId,
    required String name,
    required String addedBy,
  }) {
    return _collection(projectId).add({
      'name': name,
      'addedAt': FieldValue.serverTimestamp(),
      'addedBy': addedBy,
    });
  }

  Future<void> removeLaborer(String projectId, String laborerId) {
    return _collection(projectId).doc(laborerId).delete();
  }
}
