import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

const _greenStatuses = {'approved', 'completed', 'delivered', 'present', 'paid'};
const _orangeStatuses = {'pending', 'assigned', 'in_progress', 'dispatched'};
const _redStatuses = {'rejected', 'absent'};

/// Localizes the handful of known workflow status strings; anything else
/// (e.g. a raw value not in this fixed set) falls back to a formatted
/// version of the raw string so the chip never shows a blank label.
String? _localizedStatus(BuildContext context, String normalized) {
  final l10n = AppLocalizations.of(context)!;
  switch (normalized) {
    case 'pending':
      return l10n.statusPending;
    case 'approved':
      return l10n.statusApproved;
    case 'rejected':
      return l10n.statusRejected;
    case 'completed':
      return l10n.statusCompleted;
    case 'delivered':
      return l10n.statusDelivered;
    case 'present':
      return l10n.statusPresent;
    case 'absent':
      return l10n.statusAbsent;
    case 'assigned':
      return l10n.statusAssigned;
    case 'in_progress':
      return l10n.statusInProgress;
    case 'dispatched':
      return l10n.statusDispatched;
    case 'paid':
      return l10n.statusPaid;
    case 'submitted':
      return l10n.statusSubmitted;
    default:
      return null;
  }
}

/// A small colored pill for a status string, so lists read at a glance
/// instead of relying on plain text (green = good/done, orange = in
/// progress/waiting, red = rejected, grey = anything unrecognized).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final Color color;
    if (_greenStatuses.contains(normalized)) {
      color = Colors.green;
    } else if (_orangeStatuses.contains(normalized)) {
      color = Colors.orange;
    } else if (_redStatuses.contains(normalized)) {
      color = Colors.red;
    } else {
      color = Colors.grey;
    }

    final fallback = status.replaceAll('_', ' ');
    final displayLabel =
        _localizedStatus(context, normalized) ??
        (fallback.isEmpty ? fallback : fallback[0].toUpperCase() + fallback.substring(1));

    return Chip(
      label: Text(
        displayLabel,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
