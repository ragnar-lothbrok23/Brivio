import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../../models/app_user.dart';
import '../../services/notification_service.dart';
import '../expense/expense_screen.dart';
import '../material_request/material_request_screen.dart';
import '../purchase_order/purchase_order_screen.dart';
import '../safety/safety_checklist_screen.dart';
import '../task/my_tasks_screen.dart';
import '../task/task_screen.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_list.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key, required this.user});

  final AppUser user;
  final _notificationService = NotificationService();

  Widget? _screenFor(String? relatedCollection) {
    switch (relatedCollection) {
      case 'expenses':
        return ExpenseScreen(user: user);
      case 'material_requests':
        return MaterialRequestScreen(user: user);
      case 'purchase_orders':
        return PurchaseOrderScreen(user: user);
      case 'tasks':
        return user.isSupervisor ? MyTasksScreen(user: user) : TaskScreen(user: user);
      case 'safety_checklists':
        return SafetyChecklistScreen(user: user);
      default:
        return null;
    }
  }

  Future<void> _handleTap(BuildContext context, AppNotification notification) async {
    if (!notification.isRead) {
      await _notificationService.markAsRead(notification.id);
    }
    final screen = _screenFor(notification.relatedCollection);
    if (screen != null && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }
  }

  String _formatTime(Timestamp? timestamp) {
    final time = timestamp?.toDate();
    if (time == null) return '';
    return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<AppNotification>>(
        stream: _notificationService.streamForUser(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SkeletonList();
          }
          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              message: 'No notifications yet',
            );
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: Icon(
                  notification.isRead ? Icons.notifications_none : Icons.notifications,
                  color: notification.isRead ? null : Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text('${notification.body}\n${_formatTime(notification.createdAt)}'),
                isThreeLine: true,
                onTap: () => _handleTap(context, notification),
              );
            },
          );
        },
      ),
    );
  }
}
