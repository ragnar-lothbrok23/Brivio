import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/contractor_invoice.dart';

class ContractorInvoiceService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('contractor_invoices');

  Future<void> submitInvoice({
    required String projectId,
    required String contractorUid,
    required String contractorName,
    required double amount,
    required String invoiceBase64,
    required String note,
  }) {
    return _collection.add({
      'projectId': projectId,
      'contractorUid': contractorUid,
      'contractorName': contractorName,
      'amount': amount,
      'invoiceBase64': invoiceBase64,
      'note': note,
      'submittedAt': FieldValue.serverTimestamp(),
      'status': 'submitted',
    });
  }

  DocumentReference<Map<String, dynamic>> docRef(String id) => _collection.doc(id);

  /// Sorted client-side, same composite-index reasoning as the rest of the
  /// app's services.
  Stream<List<ContractorInvoice>> streamForProject(String projectId) {
    return _collection.where('projectId', isEqualTo: projectId).snapshots().map((snapshot) {
      final invoices = snapshot.docs.map(ContractorInvoice.fromDoc).toList();
      invoices.sort((a, b) => _compareNewestFirst(a.submittedAt, b.submittedAt));
      return invoices;
    });
  }

  Stream<List<ContractorInvoice>> streamForContractor(String contractorUid) {
    return _collection
        .where('contractorUid', isEqualTo: contractorUid)
        .snapshots()
        .map((snapshot) {
      final invoices = snapshot.docs.map(ContractorInvoice.fromDoc).toList();
      invoices.sort((a, b) => _compareNewestFirst(a.submittedAt, b.submittedAt));
      return invoices;
    });
  }

  int _compareNewestFirst(Timestamp? a, Timestamp? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return b.compareTo(a);
  }
}
