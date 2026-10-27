import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

/// Roles that can be added to a project's team via the project detail
/// screen. Builder/PM see everything so aren't included. Vendor's actual
/// work (purchase orders) is still assigned independently of this — being
/// on a project's team here is just organizational visibility for PM.
const List<String> kProjectAssignableRoles = [
  'site_engineer',
  'supervisor',
  'contractor',
  'vendor',
];

class UserService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<AppUser>> streamAssignableUsers() {
    return _collection
        .where('role', whereIn: kProjectAssignableRoles)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppUser.fromMap(doc.id, doc.data())).toList());
  }

  /// All users with a given role, regardless of project assignment — used
  /// for roles like Vendor that aren't project-scoped.
  Stream<List<AppUser>> streamUsersByRole(String role) {
    return _collection
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppUser.fromMap(doc.id, doc.data())).toList());
  }

  /// One-time lookup (not a live stream) of every uid with any of [roles] —
  /// used for broadcast-style notifications where nothing needs to keep
  /// listening afterward.
  Future<List<String>> getUidsForRoles(List<String> roles) async {
    final snapshot = await _collection.where('role', whereIn: roles).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Stream<List<AppUser>> streamUsersForProject(String projectId) {
    return _collection
        .where('assignedProjectIds', arrayContains: projectId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppUser.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> assignToProject(String uid, String projectId) {
    return _collection.doc(uid).update({
      'assignedProjectIds': FieldValue.arrayUnion([projectId]),
    });
  }

  Future<void> unassignFromProject(String uid, String projectId) {
    return _collection.doc(uid).update({
      'assignedProjectIds': FieldValue.arrayRemove([projectId]),
    });
  }
}
