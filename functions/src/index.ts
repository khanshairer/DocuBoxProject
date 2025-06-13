import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

// Initialize the Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

// Define the function using the new onSchedule v2 syntax.
export const sendExpiryReminders = onSchedule("every day 09:00", async (event) => {
  logger.info("Starting daily check for expiring documents...");

  // Define the reminder intervals in days.
  const reminderDays = [1, 7, 30, 90];

  for (const days of reminderDays) {
    // Calculate the target expiry date for the interval.
    const targetDate = new Date();
    targetDate.setDate(targetDate.getDate() + days);

    // Create a start and end of the target day to query the entire day's documents.
    const startOfDay = new Date(targetDate.setHours(0, 0, 0, 0));
    const endOfDay = new Date(targetDate.setHours(23, 59, 59, 999));

    const startTimestamp = admin.firestore.Timestamp.fromDate(startOfDay);
    const endTimestamp = admin.firestore.Timestamp.fromDate(endOfDay);

    // Query Firestore for documents expiring on the target day.
    // This will require a composite index, which Firebase will help you create via a link in the logs.
    const querySnapshot = await db.collection("documents")
      .where("expiryDate", ">=", startTimestamp)
      .where("expiryDate", "<=", endTimestamp)
      .get();

    if (querySnapshot.empty) {
      logger.info(`No documents found expiring in ${days} day(s).`);
      continue; // Move to the next reminder interval.
    }

    logger.info(`Found ${querySnapshot.size} document(s) expiring in ${days} day(s).`);

    // Process each expiring document.
    for (const doc of querySnapshot.docs) {
      const document = doc.data();
      const userId = document.userId;
      const documentName = document.name || "Untitled";

      if (!userId) {
        logger.warn(`Document ${doc.id} is missing a userId. Skipping.`);
        continue;
      }

      // Get the user's data to find their FCM device tokens.
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        logger.warn(`User ${userId} not found. Skipping.`);
        continue;
      }

      const user = userDoc.data();
      const tokens = user?.fcmTokens;

      if (user && tokens && tokens.length > 0) {
        const payload = {
          notification: {
            title: "DocuBox: Document Expiry Reminder",
            body: `Your document "${documentName}" is expiring in ${days} day(s).`,
          },
          data: {
            documentId: doc.id,
          },
        };

        logger.info(`Sending notification for document ${documentName} to user ${userId}`);
        await admin.messaging().sendToDevice(tokens, payload);
      } else {
        logger.warn(`User ${userId} has no FCM tokens. Skipping notification.`);
      }
    }
  }
  logger.info("Daily check completed.");
});