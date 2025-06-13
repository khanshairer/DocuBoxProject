// Install the Stream Chat Node.js SDK: npm install stream-chat
const functions = require('firebase-functions');
const StreamChat = require('stream-chat').StreamChat;

// IMPORTANT: Remove API_KEY/SECRET declarations and serverClient initialization from top level.
// They will be moved inside the function.

exports.createStreamChatToken = functions.https.onCall(async (data, context) => {
  // Move API_KEY and API_SECRET access INSIDE the function
  const API_KEY = functions.config().stream?.api_key;
  const API_SECRET = functions.config().stream?.api_secret;

  // Add a check here for missing keys during invocation (more robust)
  if (!API_KEY || !API_SECRET) {
    console.error('Stream Chat API Key or Secret NOT configured or unavailable during invocation.');
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Stream Chat API configuration is missing or invalid. Please check Firebase Functions config.'
    );
  }

  // Initialize serverClient INSIDE the function as well
  const serverClient = StreamChat.getInstance(API_KEY, API_SECRET);

  // Ensure the user is authenticated with Firebase before generating a token
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'The function must be called while authenticated.'
    );
  }

  const uid = context.auth.uid; // Get the user's UID from Firebase Auth context

  try {
    // Generate the user token using the server-side Stream Chat client
    const token = serverClient.createToken(uid);
    return { token: token }; // Return the token to the Flutter app
  } catch (error) {
    console.error('Error generating Stream Chat token:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to generate Stream Chat token. Please check server logs.',
      error.message // Pass the original error message for debugging
    );
  }
});