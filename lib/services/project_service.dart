import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/project.dart';

class ProjectService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('projects');

  Future<void> createProject({
    required String name,
    required String client,
    required double budget,
    required String createdByUid,
    String location = '',
  }) async {
    final coordinates = location.trim().isEmpty ? null : await _geocode(location.trim());
    await _collection.add({
      'name': name,
      'client': client,
      'budget': budget,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdByUid,
      'location': location.trim(),
      if (coordinates != null) 'latitude': coordinates.$1,
      if (coordinates != null) 'longitude': coordinates.$2,
    });
  }

  /// Resolves a free-text place name to coordinates via Open-Meteo's free
  /// geocoding API (no key required). Returns null on no match or any
  /// network/parse failure — the project is still created either way, just
  /// without a weather card until location is fixed.
  Future<(double, double)?> _geocode(String place) async {
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': place,
        'count': '1',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final results = (jsonDecode(response.body) as Map<String, dynamic>)['results'] as List?;
      if (results == null || results.isEmpty) return null;
      final first = results.first as Map<String, dynamic>;
      return ((first['latitude'] as num).toDouble(), (first['longitude'] as num).toDouble());
    } catch (_) {
      return null;
    }
  }

  Stream<Project?> streamProject(String projectId) {
    return _collection.doc(projectId).snapshots().map(
          (doc) => doc.exists ? Project.fromDoc(doc) : null,
        );
  }

  Future<void> setContractorScope(String projectId, String contractorUid, String scope) {
    return _collection.doc(projectId).update({'contractorScopes.$contractorUid': scope});
  }

  /// Re-geocodes [location] (or clears coordinates if left blank) and
  /// updates the project doc — same geocoding path as `createProject`, so
  /// editing an older project (or fixing a bad match) gets it a weather
  /// card too.
  Future<void> updateLocation(String projectId, String location) async {
    final trimmed = location.trim();
    final coordinates = trimmed.isEmpty ? null : await _geocode(trimmed);
    await _collection.doc(projectId).update({
      'location': trimmed,
      'latitude': coordinates?.$1,
      'longitude': coordinates?.$2,
    });
  }

  Stream<List<Project>> streamAllProjects() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Project.fromDoc).toList());
  }

  /// Builder/PM see every project; every other role only sees the ones
  /// they're assigned to.
  Stream<List<Project>> streamProjectsForUser(AppUser user) {
    if (user.canViewAllProjects) return streamAllProjects();
    return streamAllProjects().map(
      (projects) => projects.where((p) => user.assignedProjectIds.contains(p.id)).toList(),
    );
  }
}
