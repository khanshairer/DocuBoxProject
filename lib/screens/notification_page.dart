import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_state_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  Future<void> markAsRead(WidgetRef ref, String docId) async {
    final user = ref.read(authStateProvider).currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(docId)
        .update({'read': true});

    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsCountProvider);
  }

  Future<void> deleteNotification(WidgetRef ref, String docId) async {
    final user = ref.read(authStateProvider).currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(docId)
        .delete();

    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsCountProvider);
  }

  Future<void> clearAllNotifications(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).currentUser;
    if (user == null) return;

    final notifRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications');

    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await notifRef.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsCountProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications cleared')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear All Notifications?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await clearAllNotifications(context, ref);
              }
            },
          )
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          final sortedNotifs = [...notifications]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            itemCount: sortedNotifs.length,
            itemBuilder: (context, index) {
              final notif = sortedNotifs[index];
              final created = notif.createdAt;
              final formattedTime =
                  '${created.day}/${created.month} ${created.hour}:${created.minute.toString().padLeft(2, '0')}';

              return Dismissible(
                key: Key(notif.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await deleteNotification(ref, notif.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Notification deleted'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: ListTile(
                  leading: Icon(
                    notif.read ? Icons.mark_email_read : Icons.notifications,
                    color: notif.read ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight:
                          notif.read ? FontWeight.normal : FontWeight.bold,
                      color: notif.read ? Colors.black : Colors.blue.shade800,
                    ),
                  ),
                  subtitle: Text(
                    notif.body,
                    style: TextStyle(
                      fontWeight:
                          notif.read ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    formattedTime,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  onTap: () async {
                    final user = ref.read(authStateProvider).currentUser;
                    if (user == null) return;

                    await markAsRead(ref, notif.id);

                    if (notif.documentId != null && notif.type == 'shared') {
                      if (context.mounted) {
                        context.pushNamed(
                          'shared-document-view',
                          extra: notif.documentId,
                        );
                      }
                    } else if (notif.documentId != null && notif.type == 'expiry') {
                      if (context.mounted) {
                        context.pushNamed(
                          'view-document',
                          extra: notif.documentId,
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
