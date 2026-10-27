import 'package:cloud_firestore/cloud_firestore.dart';

/// Fixed set of items every safety checklist is conducted against.
const List<String> kSafetyChecklistItems = [
  'Hard hats worn by all workers',
  'Fire extinguishers accessible',
  'Scaffolding and ladders secured',
  'First aid kit available on site',
  'Warning signage displayed',
  'Electrical hazards covered or marked',
];

class SafetyChecklistItem {
  const SafetyChecklistItem({required this.label, required this.checked});

  factory SafetyChecklistItem.fromMap(Map<String, dynamic> map) {
    return SafetyChecklistItem(
      label: map['label'] as String? ?? '',
      checked: map['checked'] as bool? ?? false,
    );
  }

  final String label;
  final bool checked;

  Map<String, dynamic> toMap() => {'label': label, 'checked': checked};
}

class SafetyChecklist {
  const SafetyChecklist({
    required this.id,
    required this.projectId,
    required this.conductedByUid,
    required this.conductedByName,
    required this.date,
    required this.items,
    required this.notes,
    required this.createdAt,
  });

  factory SafetyChecklist.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final rawItems = data['items'] as List<dynamic>? ?? const [];
    return SafetyChecklist(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      conductedByUid: data['conductedByUid'] as String? ?? '',
      conductedByName: data['conductedByName'] as String? ?? '',
      date: data['date'] as String,
      items: rawItems
          .map((item) => SafetyChecklistItem.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      notes: data['notes'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  final String id;
  final String projectId;
  final String conductedByUid;
  final String conductedByName;
  final String date; // yyyy-MM-dd
  final List<SafetyChecklistItem> items;
  final String notes;
  final Timestamp? createdAt;
}
