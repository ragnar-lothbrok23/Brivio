import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/app_user.dart';

/// Single shared Razorpay checkout flow, reused by both the Vendor PO
/// payment and the Contractor invoice payment — TEST MODE ONLY (the key
/// below is a `rzp_test_` key, which Razorpay only ever lets process
/// simulated payments, regardless of what card/UPI details are entered).
class PaymentService {
  static const _testKeyId = 'rzp_test_TQURXu13gYyWOT';

  /// Opens Razorpay checkout for [amount] (rupees). On success, updates
  /// [docRef] with status "paid", the returned payment ID, and a server
  /// timestamp. On failure/cancellation, [docRef] is left untouched.
  /// [onSettled] always fires exactly once, regardless of outcome, so a
  /// caller (e.g. a button) can reset any "processing" UI state.
  void payAndMarkPaid({
    required BuildContext context,
    required double amount,
    required String description,
    required DocumentReference<Map<String, dynamic>> docRef,
    required AppUser payer,
    VoidCallback? onSettled,
  }) {
    final razorpay = Razorpay();

    void finish() {
      razorpay.clear();
      onSettled?.call();
    }

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
      try {
        await docRef.update({
          'status': 'paid',
          'paymentId': response.paymentId,
          'paidAt': FieldValue.serverTimestamp(),
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Paid, but failed to update the record: $e')),
          );
        }
      } finally {
        finish();
      }
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${response.message ?? 'cancelled'}')),
        );
      }
      finish();
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      finish();
    });

    razorpay.open({
      'key': _testKeyId,
      'amount': (amount * 100).round(),
      'name': 'Brivio',
      'description': description,
      'prefill': {'email': payer.email},
      'theme': {'color': '#1B3A57'},
    });
  }
}
