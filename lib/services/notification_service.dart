// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// This is a top-level function, not part of any class.
// It's required for handling messages when the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using them.
  // await Firebase.initializeApp(); // We don't need this for just printing.

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
  }
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Set a handler for messages received when the app is in the background or terminated.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handler for messages received while the app is in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Here you could show a local notification using a package like flutter_local_notifications
        // to make the user aware of the message. The OS does not show a notification banner
        // for foreground apps by default.
      }
    });

    // Handler for when a user taps a notification, opening the app from a background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
        print('Message data: ${message.data}');
      }
      _handleNotificationNavigation(message.data);
    });

    // Check if the app was launched from a terminated state by a notification.
    _setupTerminatedStateInteraction();
  }

  Future<void> _setupTerminatedStateInteraction() async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      // If the message contains a data property, handle navigation.
      if (kDebugMode) {
        print('App opened from terminated state by a notification:');
        print('Message data: ${initialMessage.data}');
      }
      _handleNotificationNavigation(initialMessage.data);
    }
  }
  
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // This is where you'll handle navigation.
    // Our Cloud Function will send a 'documentId' in the data payload.
    final documentId = data['documentId'];
    if (documentId != null) {
      print('Navigate to document with ID: $documentId');
      // In a real scenario, you would use your GoRouter instance to navigate:
      // navigatorKey.currentContext.push('/document-details', extra: documentId);
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }
  }

  Future<String?> getToken() async {
    String? token = await _fcm.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }
    return token;
  }
}