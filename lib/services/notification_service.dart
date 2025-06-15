import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    await FirebaseMessaging.instance.requestPermission();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title ?? 'Reminder',
          body: message.notification!.body ?? '',
        );
      }
    });
  }

  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'docubox_channel',
      'DocuBox Reminders',
      channelDescription: 'Notifications for DocuBox events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  }

  /// Check for expiring documents and notify if 3 or 7 days left
  static Future<void> checkAndNotifyExpiringDocuments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    final snapshot = await firestore
        .collection('documents')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final expiry = (data['expiry'] as Timestamp).toDate();
      final name = data['name'] ?? 'Unnamed Document';
      final diffDays = expiry.difference(now).inDays;

      if (diffDays == 3 || diffDays == 7) {
        final title = 'Upcoming Document Expiry';
        final body = '$name is expiring in $diffDays days';
        final notificationId = '${doc.id}_$diffDays';

        final notifRef = firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notificationId);

        final notifDoc = await notifRef.get();

        // Always show local in-app
        await _showLocalNotification(title: title, body: body);

        if (!notifDoc.exists) {
          await notifRef.set({
            'title': title,
            'body': body,
            'createdAt': Timestamp.now(),
            'read': false,
            'type': 'expiry',
            'documentId': doc.id,
          });
        }
      }
    }
  }

  /// Triggered when a document is shared with another user
  static Future<void> notifyDocumentShared({
    required String sharedWithUid,
    required String documentName,
    required String documentId,
    required String sharedByName,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final title = 'New Shared Document';
      final body = '$sharedByName shared "$documentName" with you';
      final notificationId = 'shared_$documentId';

      final notifRef = firestore
          .collection('users')
          .doc(sharedWithUid)
          .collection('notifications')
          .doc(notificationId);

      final existing = await notifRef.get();

      if (!existing.exists) {
        print('📬 Creating notification for $sharedWithUid: $documentName');
        await notifRef.set({
          'title': title,
          'body': body,
          'createdAt': Timestamp.now(),
          'read': false,
          'type': 'shared',
          'documentId': documentId,
        });

        await _showLocalNotification(title: title, body: body);
      } else {
        print('ℹ️ Notification already exists for $sharedWithUid and $documentName');
      }
    } catch (e, st) {
      print('❌ Failed to create shared notification: $e\n$st');
    }
  }
}
