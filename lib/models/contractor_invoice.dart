import 'package:cloud_firestore/cloud_firestore.dart';

class ContractorInvoice {
  const ContractorInvoice({
    required this.id,
    required this.projectId,
    required this.contractorUid,
    required this.contractorName,
    required this.amount,
    required this.invoiceBase64,
    required this.note,
    required this.submittedAt,
    required this.status,
    this.paymentId,
    this.paidAt,
  });

  factory ContractorInvoice.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ContractorInvoice(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      contractorUid: data['contractorUid'] as String? ?? '',
      contractorName: data['contractorName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      invoiceBase64: data['invoiceBase64'] as String? ?? '',
      note: data['note'] as String? ?? '',
      submittedAt: data['submittedAt'] as Timestamp?,
      // Invoices created before payments existed have no status field yet.
      status: data['status'] as String? ?? 'submitted',
      paymentId: data['paymentId'] as String?,
      paidAt: data['paidAt'] as Timestamp?,
    );
  }

  final String id;
  final String projectId;
  final String contractorUid;
  final String contractorName;
  final double amount;
  final String invoiceBase64;
  final String note;
  final Timestamp? submittedAt;
  final String status; // 'submitted' | 'paid'
  final String? paymentId;
  final Timestamp? paidAt;

  bool get isPaid => status == 'paid';
}
