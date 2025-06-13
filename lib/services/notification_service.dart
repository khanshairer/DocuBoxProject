import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // iOS: request permissions
    await FirebaseMessaging.instance.requestPermission();

    // Android + iOS local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotificationsPlugin.initialize(initSettings);

    // Handle foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title ?? 'Reminder',
          body: message.notification!.body ?? '',
        );
      }
    });
  }

  // Add this inside NotificationService class
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
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'docubox_channel',
      'DocuBox Reminders',
      channelDescription: 'Notifications for expiring documents',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
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

  static Future<void> checkAndNotifyExpiringDocuments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('documents')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final expiry = (data['expiry'] as Timestamp).toDate();
      final name = data['name'] ?? 'Unnamed Document';
      final diffDays = expiry.difference(now).inDays;

      if (diffDays == 3 || diffDays == 7) {
        await _showLocalNotification(
          title: 'Upcoming Document Expiry',
          body: '$name is expiring in $diffDays days',
        );
      }
    }
  }
}
