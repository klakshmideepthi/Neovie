const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.checkDailyDosage = functions.pubsub.schedule("0 0 * * *").timeZone("UTC")
    .onRun(async (context) => {
        console.log("checkDailyDosage function started");
        const db = admin.firestore();
        const usersRef = db.collection("users");
        const today = new Date();
        const dayOfWeek = today.getDay();
        console.log("Current day of week:", dayOfWeek);
        const dayMap = {
            "Su": 0, "Mo": 1, "Tu": 2, "We": 3, "Th": 4, "Fr": 5, "Sa": 6,
        };
        try {
            const snapshot = await usersRef.get();
            const batch = db.batch();

            snapshot.forEach((doc) => {
                const userData = doc.data();
                const userDosageDay = userData.dosageDay ? dayMap[userData.dosageDay] : -1;
                console.log("User:", doc.id, "Dosage Day:", userData.dosageDay,
                    "Mapped Day:", userDosageDay);
                if (userDosageDay === dayOfWeek) {
                    console.log("Matching day for user:", doc.id);
                    const userRef = usersRef.doc(doc.id);
                    batch.update(userRef, {showMedicationReminder: true});
                } else {
                    const userRef = usersRef.doc(doc.id);
                    batch.update(userRef, {showMedicationReminder: false});
                }
            });
            await batch.commit();
            console.log("Daily dosage check completed and user documents updated");
            return null;
        } catch (error) {
            console.error("Error checking daily dosage:", error);
            return null;
        }
    });

exports.updateDosageDay = functions.firestore
    .document("users/{userId}")
    .onUpdate((change, context) => {
        const newValue = change.after.data();
        const previousValue = change.before.data();

        if (newValue.dosageDay !== previousValue.dosageDay) {
            const today = new Date();
            const dayOfWeek = today.getDay();
            const dayMap = {
                "Su": 0, "Mo": 1, "Tu": 2, "We": 3, "Th": 4, "Fr": 5, "Sa": 6,
            };

            const userDosageDay = newValue.dosageDay ? dayMap[newValue.dosageDay] : -1;
            if (userDosageDay === dayOfWeek) {
                return change.after.ref.update({showMedicationReminder: true});
            } else {
                return change.after.ref.update({showMedicationReminder: false});
            }
        }

        return null;
    });
