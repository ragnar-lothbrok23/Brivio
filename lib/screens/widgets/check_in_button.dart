import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/staff_check_in.dart';
import '../../services/staff_attendance_service.dart';
import '../../utils/date_format.dart';

/// Self check-in button for a given project: shows "Check In Today" until
/// pressed, then "Checked in at HH:mm" for the rest of the day.
class CheckInButton extends StatefulWidget {
  const CheckInButton({super.key, required this.user, required this.projectId});

  final AppUser user;
  final String? projectId;

  @override
  State<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton> {
  final _service = StaffAttendanceService();
  late final String _today = formatDate(DateTime.now());

  String? _futureProjectId;
  Future<StaffCheckIn?>? _future;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ensureFuture();
  }

  @override
  void didUpdateWidget(covariant CheckInButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureFuture();
  }

  void _ensureFuture() {
    if (widget.projectId != null && widget.projectId != _futureProjectId) {
      _futureProjectId = widget.projectId;
      _future = _service.getCheckInForToday(widget.projectId!, widget.user.uid, _today);
    }
  }

  Future<void> _checkIn() async {
    final projectId = widget.projectId;
    if (projectId == null) return;
    setState(() => _isSaving = true);
    try {
      await _service.checkIn(
        projectId: projectId,
        userId: widget.user.uid,
        userName: widget.user.name,
        role: widget.user.role,
        date: _today,
      );
      setState(() {
        _future = _service.getCheckInForToday(projectId, widget.user.uid, _today);
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.projectId == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<StaffCheckIn?>(
        future: _future,
        builder: (context, snapshot) {
          final checkIn = snapshot.data;
          if (checkIn != null) {
            final time = checkIn.checkedInAt?.toDate();
            final timeLabel = time == null
                ? ''
                : ' at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            return OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.check_circle),
              label: Text('Checked in$timeLabel'),
            );
          }
          return _isSaving
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  onPressed: _checkIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Check In Today'),
                );
        },
      ),
    );
  }
}
