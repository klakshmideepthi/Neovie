const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.updateUserAges = functions.pubsub.schedule("every 24 hours").onRun(async (context) => {
    const usersSnapshot = await admin.firestore().collection("users").get();
    const updatePromises = usersSnapshot.docs.map(async (doc) => {
        const userData = doc.data();
        if (userData.dateOfBirth) {
            const dateOfBirth = userData.dateOfBirth.toDate();
            const ageInMilliseconds = Date.now() - dateOfBirth.getTime();
            const ageInYears = Math.floor(ageInMilliseconds / 31557600000);
            return doc.ref.update({age: ageInYears});
        }
    });
    await Promise.all(updatePromises);
    console.log("All user ages updated successfully");
    return null;
});
