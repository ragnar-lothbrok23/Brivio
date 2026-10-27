import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TaskService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required String assignedToUid,
    required String assignedToName,
    required String createdBy,
    String? dueDate,
  }) {
    return _collection.add({
      'projectId': projectId,
      'title': title,
      'description': description,
      'assignedToUid': assignedToUid,
      'assignedToName': assignedToName,
      'status': 'assigned',
      'createdBy': createdBy,
      'dueDate': dueDate,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String taskId, String status) {
    return _collection.doc(taskId).update({'status': status});
  }

  /// Sorted client-side so this doesn't require a composite Firestore index
  /// for the assignedToUid equality + createdAt ordering combination.
  Stream<List<Task>> streamTasksForUser(String uid) {
    return _collection.where('assignedToUid', isEqualTo: uid).snapshots().map((snapshot) {
      final tasks = snapshot.docs.map(Task.fromDoc).toList();
      tasks.sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
      return tasks;
    });
  }

  Stream<List<Task>> streamTasksForProject(String projectId) {
    return _collection.where('projectId', isEqualTo: projectId).snapshots().map((snapshot) {
      final tasks = snapshot.docs.map(Task.fromDoc).toList();
      tasks.sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
      return tasks;
    });
  }

  int _compareNewestFirst(Timestamp? a, Timestamp? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return b.compareTo(a);
  }
}
