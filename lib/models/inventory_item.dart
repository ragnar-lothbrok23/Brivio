import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.projectId,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory InventoryItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return InventoryItem(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unit: data['unit'] as String? ?? '',
    );
  }

  final String id;
  final String projectId;
  final String name;
  final int quantity;
  final String unit;
}
