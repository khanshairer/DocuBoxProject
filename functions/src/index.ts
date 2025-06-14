import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

export const sendExpiryNotifications = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    const now = new Date();
    const usersSnapshot = await db.collection("users").get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const fcmToken = userDoc.data().fcmToken;
      const notificationsEnabled = userDoc.data().notificationsEnabled ?? true;

      if (!fcmToken || !notificationsEnabled) {
        console.log(`⏭️ Skipping ${userId} - No token or notifications disabled.`);
        continue;
      }

      const docsSnapshot = await db
        .collection("documents")
        .where("userId", "==", userId)
        .get();

      for (const doc of docsSnapshot.docs) {
        const data = doc.data();

        const expiry: admin.firestore.Timestamp = data.expiry;
        const expiryDate = expiry.toDate();

        const daysLeft = Math.floor(
          (expiryDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
        );

        if (daysLeft === 3 || daysLeft === 7) {
          const docName = data.name || "Unnamed Document";
          const body = `${docName} is expiring in ${daysLeft} days.`;

          const message = {
            token: fcmToken,
            notification: {
              title: "📁 Document Expiry Reminder",
              body: body,
            },
          };

          try {
            await messaging.send(message);
            console.log(`✅ Sent to ${userId}: ${docName} (${daysLeft} days left)`);

            // ⬇️ Save to Firestore notifications
            await db
              .collection("users")
              .doc(userId)
              .collection("notifications")
              .add({
                title: "📁 Document Expiry Reminder",
                body: body,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                read: false,
              });

          } catch (error) {
            console.error(`❌ Error sending to ${userId}:`, error);
          }
        }
      }
    }

    return null;
  });
