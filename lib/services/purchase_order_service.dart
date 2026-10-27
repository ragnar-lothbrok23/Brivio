import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/material_request.dart';
import '../models/purchase_order.dart';

class PurchaseOrderService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('purchase_orders');

  Future<void> createFromRequest({
    required MaterialRequest request,
    required String vendorUid,
    required String vendorName,
  }) {
    return _collection.add({
      'projectId': request.projectId,
      'materialRequestId': request.id,
      'itemName': request.itemName,
      'quantity': request.quantity,
      'unit': request.unit,
      'vendorUid': vendorUid,
      'vendorName': vendorName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String poId, String status) {
    return _collection.doc(poId).update({'status': status});
  }

  DocumentReference<Map<String, dynamic>> docRef(String id) => _collection.doc(id);

  Future<void> submitInvoice({
    required String poId,
    required String invoiceBase64,
    required double invoiceAmount,
  }) {
    return _collection.doc(poId).update({
      'invoiceBase64': invoiceBase64,
      'invoiceAmount': invoiceAmount,
      'invoiceSubmittedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sorted client-side, same reasoning as `MaterialRequestService`.
  Stream<List<PurchaseOrder>> streamForProject(String projectId) {
    return _collection.where('projectId', isEqualTo: projectId).snapshots().map((snapshot) {
      final orders = snapshot.docs.map(PurchaseOrder.fromDoc).toList();
      orders.sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
      return orders;
    });
  }

  Stream<List<PurchaseOrder>> streamForVendor(String vendorUid) {
    return _collection.where('vendorUid', isEqualTo: vendorUid).snapshots().map((snapshot) {
      final orders = snapshot.docs.map(PurchaseOrder.fromDoc).toList();
      orders.sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
      return orders;
    });
  }

  int _compareNewestFirst(Timestamp? a, Timestamp? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return b.compareTo(a);
  }
}
