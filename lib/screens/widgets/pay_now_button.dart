import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/payment_service.dart';
import '../auth/auth_colors.dart';

/// Shared "Pay Now" control for the Vendor PO and Contractor invoice
/// payment flows — same button, same Razorpay checkout, everywhere it's
/// used, so both flows feel like the same feature rather than two
/// bolted-on ones.
class PayNowButton extends StatefulWidget {
  const PayNowButton({
    super.key,
    required this.amount,
    required this.description,
    required this.docRef,
    required this.payer,
  });

  final double amount;
  final String description;
  final DocumentReference<Map<String, dynamic>> docRef;
  final AppUser payer;

  @override
  State<PayNowButton> createState() => _PayNowButtonState();
}

class _PayNowButtonState extends State<PayNowButton> {
  final _paymentService = PaymentService();
  bool _isProcessing = false;

  void _pay() {
    setState(() => _isProcessing = true);
    _paymentService.payAndMarkPaid(
      context: context,
      amount: widget.amount,
      description: widget.description,
      docRef: widget.docRef,
      payer: widget.payer,
      onSettled: () {
        if (mounted) setState(() => _isProcessing = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : _pay,
      style: ElevatedButton.styleFrom(backgroundColor: kAuthNavy, foregroundColor: Colors.white),
      icon: _isProcessing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.payment, size: 18),
      label: Text(_isProcessing ? 'Processing...' : 'Pay Now'),
    );
  }
}
