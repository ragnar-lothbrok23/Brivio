import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.client,
    required this.budget,
    required this.status,
    this.contractorScopes = const {},
    this.location = '',
    this.latitude,
    this.longitude,
  });

  factory Project.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Project(
      id: doc.id,
      name: data['name'] as String? ?? '',
      client: data['client'] as String? ?? '',
      budget: (data['budget'] as num?)?.toDouble() ?? 0,
      status: data['status'] as String? ?? 'active',
      contractorScopes: (data['contractorScopes'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as String? ?? '')) ??
          const {},
      location: data['location'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String name;
  final String client;
  final double budget;
  final String status;

  /// uid -> scope-of-work description, set by PM for Contractor team members.
  final Map<String, String> contractorScopes;

  /// Free-text place name entered at project creation (e.g. "Chennai"),
  /// geocoded once into [latitude]/[longitude] for the weather card on the
  /// Daily Progress Log screen. Empty/null when not set or geocoding failed.
  final String location;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;
}
