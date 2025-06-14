// web/firebase-messaging-sw.js

importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// Initialize your firebase app in the service worker scope:
firebase.initializeApp({
  apiKey: '…',
  authDomain: '…',
  projectId: '…',
  messagingSenderId: '…',
  appId: '…',
});

const messaging = firebase.messaging();

// Optional: handle background messages
messaging.onBackgroundMessage(payload => {
  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
  });
});
