import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.projectId,
    required this.materialRequestId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.vendorUid,
    required this.vendorName,
    required this.status,
    required this.createdAt,
    this.invoiceBase64,
    this.invoiceAmount,
    this.invoiceSubmittedAt,
    this.paymentId,
    this.paidAt,
  });

  factory PurchaseOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PurchaseOrder(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      materialRequestId: data['materialRequestId'] as String? ?? '',
      itemName: data['itemName'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unit: data['unit'] as String? ?? '',
      vendorUid: data['vendorUid'] as String? ?? '',
      vendorName: data['vendorName'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: data['createdAt'] as Timestamp?,
      invoiceBase64: data['invoiceBase64'] as String?,
      invoiceAmount: (data['invoiceAmount'] as num?)?.toDouble(),
      invoiceSubmittedAt: data['invoiceSubmittedAt'] as Timestamp?,
      paymentId: data['paymentId'] as String?,
      paidAt: data['paidAt'] as Timestamp?,
    );
  }

  final String id;
  final String projectId;
  final String materialRequestId;
  final String itemName;
  final int quantity;
  final String unit;
  final String vendorUid;
  final String vendorName;
  final String status; // 'pending' | 'dispatched' | 'delivered'
  final Timestamp? createdAt;
  final String? invoiceBase64;
  final double? invoiceAmount;
  final Timestamp? invoiceSubmittedAt;
  final String? paymentId;
  final Timestamp? paidAt;

  bool get hasInvoice => invoiceBase64 != null && invoiceBase64!.isNotEmpty;
  bool get isPaid => status == 'paid';
}
