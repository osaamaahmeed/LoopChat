// Import the v2 function for Realtime Database triggers
const {onValueWritten} = require("firebase-functions/v2/database");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");

admin.initializeApp();

// ========================================================================
// FUNCTION 1: Counts how many users are currently online.
// ========================================================================
exports.onUserStatusChanged = onValueWritten("/status/{uid}", (event) => {
  const beforeData = event.data.before.val();
  const afterData = event.data.after.val();
  const wasOnline = (beforeData && beforeData.isOnline) || false;
  const isOnline = (afterData && afterData.isOnline) || false;
  const counterRef = admin.database().ref("/online_users_count");

  if (wasOnline === isOnline) {
    return null;
  }
  if (!wasOnline && isOnline) {
    return counterRef.set(admin.database.ServerValue.increment(1));
  }
  if (wasOnline && !isOnline) {
    return counterRef.set(admin.database.ServerValue.increment(-1));
  }
  return null;
});


// ========================================================================
// FUNCTION 2: Resets message limits for all users every day at midnight.
// ========================================================================
exports.resetDailyMessageCounts = onSchedule("0 0 * * *", async (event) => {
  const db = admin.firestore();
  logger.log("Starting daily message count reset.");

  // This query finds all users who have a message count greater than 0
  const snapshot = await db.collection("users").get();

  if (snapshot.empty) {
    logger.log("No users needed a message count reset.");
    return null;
  }

  // A "batch" is an efficient way to make many changes at once
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    // Set the count back to 0 for each user
    batch.update(doc.ref, {leftMessages: 200});
  });

  await batch.commit();
  logger.log(`Reset message count for ${snapshot.size} users.`);
  return null;
});


exports.registerUserWithDeviceCheck =
functions.https.onCall(async (data, context) => {
  const {email, password, deviceId, username} = data.data;
  console.log("Received data:", data);
  const MAX_ACCOUNTS_PER_DEVICE = 2;

  // --- FIXED VALIDATION BLOCK ---
  if (
    !email || email.trim() === "" ||
    !password || password.trim() === "" ||
    !username || username.trim() === "" ||
    !deviceId || deviceId.trim() === ""
  ) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        // Updated error message for clarity
        "Required fields (email, password, username, deviceId) are missing.",
    );
  }

  const db = admin.firestore();
  const usersRef = db.collection("users");

  // Check if username is taken
  const usernameSnapshot =
    await usersRef.where("username", "==", username).get();
  if (!usernameSnapshot.empty) {
    // --- IMPROVED ERROR ---
    throw new functions.https.HttpsError(
        "already-exists", // Use a standard error code
        "This username is already taken. Please choose another.",
    );
  }

  // Check device limit
  const deviceSnapshot =
    await usersRef.where("deviceId", "==", deviceId).get();
  if (deviceSnapshot.size >= MAX_ACCOUNTS_PER_DEVICE) {
    throw new functions.https.HttpsError(
        "resource-exhausted",
        "The account limit for this device has been reached.",
    );
  }

  // Create user if all checks pass
  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: username, // Good practice to add username here
    });
    await db.collection("users").doc(userRecord.uid).set({
      email: email,
      username: username,
      deviceId: deviceId,
      leftMessages: 200,
      uid: userRecord.uid, // Good to store the UID in the doc as well
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // await db.collection("users").doc(userRecord.uid).set({
    //   email: email,
    //   username: username,
    //   deviceId: deviceId,
    //   leftMessages: 200,
    //   // It's good to add a timestamp
    //   // createdAt: admin.firestore.FieldValue.serverTimestamp(),
    // });
    // await db.collection("users").add({email: email,
    //   username: username,
    //   deviceId: deviceId,
    //   leftMessages: 200,
    // });

    return {status: "success", uid: userRecord.uid};
  } catch (error) {
    // This will catch errors like 'auth/email-already-exists'
    throw new functions.https.HttpsError("internal", error.message);
  }
});
