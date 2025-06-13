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

      if (!fcmToken) {
        console.log(`User ${userId} has no FCM token. Skipping.`);
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

          const message = {
            token: fcmToken,
            notification: {
              title: "📁 Document Expiry Reminder",
              body: `${docName} is expiring in ${daysLeft} days.`,
            },
          };

          try {
            await messaging.send(message);
            console.log(`✅ Sent to ${userId}: ${docName} (${daysLeft} days left)`);
          } catch (error) {
            console.error(`❌ Error sending to ${userId}:`, error);
          }
        }
      }
    }

    return null;
  });
