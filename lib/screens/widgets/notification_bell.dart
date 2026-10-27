import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../../models/app_user.dart';
import '../../services/notification_service.dart';
import '../notifications/notifications_screen.dart';

class NotificationBell extends StatelessWidget {
  NotificationBell({super.key, required this.user});

  final AppUser user;
  final _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppNotification>>(
      stream: _notificationService.streamForUser(user.uid),
      builder: (context, snapshot) {
        final unreadCount = (snapshot.data ?? const <AppNotification>[])
            .where((n) => !n.isRead)
            .length;
        return IconButton(
          icon: Badge(
            label: Text('$unreadCount'),
            isLabelVisible: unreadCount > 0,
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NotificationsScreen(user: user)),
            );
          },
        );
      },
    );
  }
}
