import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_state_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    // Mark all as read when the page builds
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(authStateProvider).currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        doc.reference.update({'read': true});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                leading: Icon(
                  notif.read
                      ? Icons.mark_email_read_outlined
                      : Icons.notifications_active_outlined,
                ),
                title: Text(notif.title),
                subtitle: Text(notif.body),
                trailing: Text(
                  '${notif.createdAt.day}/${notif.createdAt.month} '
                  '${notif.createdAt.hour}:${notif.createdAt.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
