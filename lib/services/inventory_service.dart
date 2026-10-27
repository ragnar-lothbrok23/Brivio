import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_item.dart';

class InventoryService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('inventory_items');

  /// Single `.where()` on projectId — sorted client-side so this doesn't
  /// require a composite Firestore index, same as the rest of the app.
  Stream<List<InventoryItem>> streamForProject(String projectId) {
    return _collection.where('projectId', isEqualTo: projectId).snapshots().map((snapshot) {
      final items = snapshot.docs.map(InventoryItem.fromDoc).toList();
      items.sort((a, b) => a.name.compareTo(b.name));
      return items;
    });
  }

  Future<void> addItem({
    required String projectId,
    required String name,
    required int quantity,
    required String unit,
  }) {
    return _collection.add({
      'projectId': projectId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> adjustQuantity(String itemId, int delta) {
    return _collection.doc(itemId).update({
      'quantity': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteItem(String itemId) {
    return _collection.doc(itemId).delete();
  }
}
