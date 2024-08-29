const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.checkDailyDosage = functions.pubsub.schedule("0 0 * * *")
    .onRun(async (context) => {
      console.log("checkDailyDosage function started");
      const db = admin.firestore();
      const usersRef = db.collection("users");
      const today = new Date();
      const dayOfWeek = today.getDay();
      console.log("Current day of week:", dayOfWeek);
      const dayMap = {
        Su: 0,
        Mo: 1,
        Tu: 2,
        We: 3,
        Th: 4,
        Fr: 5,
        Sa: 6,
      };
      try {
        const snapshot = await usersRef.get();
        const batch = db.batch();

        snapshot.forEach((doc) => {
          const userData = doc.data();
          const userDosageDay = userData.dosageDay?
            dayMap[userData.dosageDay]:-1;
          console.log(
              "User:",
              doc.id,
              "Dosage Day:",
              userData.dosageDay,
              "Mapped Day:",
              userDosageDay,
          );
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
          Su: 0,
          Mo: 1,
          Tu: 2,
          We: 3,
          Th: 4,
          Fr: 5,
          Sa: 6,
        };

        const userDosageDay = newValue.dosageDay?dayMap[newValue.dosageDay]:-1;
        if (userDosageDay === dayOfWeek) {
          return change.after.ref.update({showMedicationReminder: true});
        } else {
          return change.after.ref.update({showMedicationReminder: false});
        }
      }

      return null;
    });

exports.updateUserAges = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async (context) => {
      console.log("Starting daily user age update");
      const usersSnapshot = await admin.firestore().collection("users").get();
      console.log(`Found ${usersSnapshot.size} users to process`);
      let updatedCount = 0;
      let errorCount = 0;
      const updatePromises = usersSnapshot.docs.map(async (doc) => {
        try {
          const userData = doc.data();
          if (userData.dateOfBirth) {
            const dateOfBirth = userData.dateOfBirth.toDate();
            const ageInMilliseconds = Date.now() - dateOfBirth.getTime();
            const ageInYears = Math.floor(ageInMilliseconds / 31557600000);
            const currentAge = userData.age || 0;
            if (ageInYears !== currentAge) {
              await doc.ref.update({age: ageInYears});
              console.log(
                  `Updated age of ${doc.id} from ${currentAge}
                   to ${ageInYears}`,
              );
              updatedCount++;
            }
          }
        } catch (error) {
          console.error(`Error updating age for user ${doc.id}:`, error);
          errorCount++;
        }
      });

      await Promise.all(updatePromises);
      console.log(
          `User age updated. Updated: ${updatedCount}, Errors: ${errorCount}`,
      );
      return null;
    });

/**
 * Retrieves user data from Firestore.
 * @param {string} userId - The ID of the user.
 * @return {Promise<Object>} The user's data.
 * @throws {functions.https.HttpsError}
 */
async function getUserData(userId) {
  if (!userId) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "User ID is required",
    );
  }

  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) {
    throw new functions.https.HttpsError("not-found", "User not found");
  }
  return userDoc.data();
}

/**
 * Creates a prompt for the AI to generate a personalized weight loss plan.
 * @param {Object} userData - The user's profile data.
 * @return {string} The formatted prompt for the AI.
 */
function createPrompt(userData) {
  const safeUserData = {
    name: userData.name || "Not provided",
    height: userData.heightCm || "Not provided",
    weight: userData.weight || "Not provided",
    targetWeight: userData.targetWeight || "Not provided",
    gender: userData.gender || "Not provided",
    age: userData.age || "Not provided",
    activityLevel: userData.activityLevel || "Not provided",
    medicalConditions:
        Array.isArray(userData.medicalConditions)?
        userData.medicalConditions.join(", "):"None",
    dietaryPreferences:
        Array.isArray(userData.dietaryPreferences)?
        userData.dietaryPreferences.join(", "):"None",
  };

  const userInfo = `
    Name: ${safeUserData.name}
    Height: ${safeUserData.heightCm}
    Current Weight: ${safeUserData.weight}
    Target Weight: ${safeUserData.targetWeight}
    Gender: ${safeUserData.gender}
    Age: ${safeUserData.age}
    Activity Level: ${safeUserData.activityLevel}
    Medical Conditions: ${safeUserData.medicalConditions}
    Dietary Preferences: ${safeUserData.dietaryPreferences}
    `;

  return `
    You are a knowledgeable and compassionate weight loss expert. Your 
    task is to provide personalized advice and create a weight loss plan based
     on the user's information and goals. Always prioritize safe, sustainable 
    weight loss methods and consider the individual's unique circumstances.

    Some information might be missing or marked as "Not provided". In these 
    cases, provide general advice and explain how more specific recommendations 
    could be given if that information was available.

    User Information:
    ${userInfo}

    Based on the available information, create a personalized weight loss plan 
    that includes the following elements (where possible):

    1. A realistic and healthy weight loss target
    2. Recommended daily calorie intake (if possible to estimate)
    3. Macronutrient balance (protein, carbohydrates, and fats)
    4. Suggested meal plan structure
    5. Types of foods to include and avoid
    6. Recommended exercise routine
    7. Lifestyle changes to support weight loss
    8. Potential challenges and how to overcome them

    If certain recommendations cannot be made due to missing information, 
    explain why and provide general advice instead.

    Present your weight loss plan in a clear, organized manner. Use bullet 
    points or numbered lists where appropriate to enhance readability. Begin 
    your response with a brief, encouraging introduction, and end with a 
    motivational conclusion.Provide your complete response within 
    <weight_loss_plan> tags. Remember to be supportive, informative, 
    and focus on promoting healthy,  sustainable weight loss practices.
    `;
}

/**
 * Creates a context string for the AI based on the user's data.
 * @param {Object} userData - The user's profile data.
 * @return {string} The formatted context string.
 */
function createContext(userData) {
  // Similar changes as in createPrompt function
  const medicalConditions =
    Array.isArray(userData.medicalConditions)?userData.medicalConditions:[];
  const dietaryPreferences =
    Array.isArray(userData.dietaryPreferences)?userData.dietaryPreferences:[];

  return `
    User Profile:
    - Name: ${userData.name || "Not provided"}
    - Height: ${userData.heightCm || "Not provided"} cm
    - Current Weight: ${userData.weight || "Not provided"} kg
    - Target Weight: ${userData.targetWeight || "Not provided"} kg
    - Gender: ${userData.gender || "Not provided"}
    - Age: ${userData.age || "Not provided"}
    - Activity Level: ${userData.activityLevel || "Not provided"}
    - Medical Conditions: ${medicalConditions.join(", ") || "None"}
    - Dietary Preferences: ${dietaryPreferences.join(", ") || "None"}
    
    This user has requested a personalized weight loss plan. When creating 
    the plan, consider their current weight, target weight, activity level, 
    and any medical conditions or dietary preferences. Provide advice that 
    aligns with their goals and circumstances. Focus on safe, sustainable 
    weight loss practices.
    `;
}

exports.generateWeightLossPlan = functions
    .region("us-west1")
    .https.onCall(async (data, context) => {
      if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "Authentication required",
        );
      }

      const userId = context.auth.uid;

      if (!userId) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "User ID is required",
        );
      }

      const apiKey = functions.config().anthropic.api_key;

      try {
        const userData = await getUserData(userId);
        const prompt = createPrompt(userData);

        console.log("User Data:", JSON.stringify(userData));
        console.log("Prompt:", prompt);

        const response = await axios.post(
            "https://api.anthropic.com/v1/messages",
            {
              model: "claude-3-5-sonnet-20240620",
              messages: [
                {
                  role: "user",
                  content: prompt,
                },
              ],
              max_tokens: 1000,
            },
            {
              headers: {
                "Content-Type": "application/json",
                "x-api-key": apiKey,
                "anthropic-version": "2023-06-01",
              },
            },
        );

        return response.data.content[0].text;
      } catch (error) {
        console.error("Error generating weight loss plan:", error);
        if (error.response) {
          console.error("Response data:", error.response.data);
          console.error("Response status:", error.response.status);
          console.error("Response headers:", error.response.headers);
        }
        throw new functions.https.HttpsError(
            "internal",
            "Error generating weight loss plan: " + error.message,
        );
      }
    });

exports.callAnthropicAPI = functions
    .region("us-west1")
    .https.onCall(async (data, context) => {
      if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "Authentication required",
        );
      }

      const apiKey = functions.config().anthropic.api_key;
      const {message, userId} = data;

      if (!message || !userId) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "The function must be called with 'message' and 'userId'.",
        );
      }

      try {
        const userData = await getUserData(userId);
        const userContext = createContext(userData);

        const prompt = `
            You are a knowledgeable and supportive AI assistant specializing in 
            personalized weight loss advice. Your responses should be based 
            on the user's specific weight loss plan and goals. Here's 
            the context of the user's weight loss plan:

            ${userContext}

            Now, please respond to the following user query while 
            taking into account their personalized weight loss plan:

            User: ${message}

            Assistant:
            `;

        const response = await axios.post(
            "https://api.anthropic.com/v1/messages",
            {
              model: "claude-3-5-sonnet-20240620",
              messages: [
                {
                  role: "user",
                  content: prompt,
                },
              ],
              max_tokens: 500,
              stream: true,
            },
            {
              headers: {
                "Content-Type": "application/json",
                "x-api-key": apiKey,
                "anthropic-version": "2023-06-01",
              },
              responseType: "stream",
            },
        );

        return new Promise((resolve, reject) => {
          let responseText = "";
          response.data.on("data", (chunk) => {
            const lines = chunk
                .toString()
                .split("\n")
                .filter((line) => line.trim() !== "");
            for (const line of lines) {
              if (line.startsWith("data:")) {
                const data = JSON.parse(line.slice(5));
                if (data.type === "content_block_delta") {
                  responseText += data.delta.text;
                }
              }
            }
          });

          response.data.on("end", () => {
            resolve(responseText);
          });

          response.data.on("error", (error) => {
            reject(
                new functions.https.HttpsError(
                    "internal",
                    "Stream error: " + error.message,
                ),
            );
          });
        });
      } catch (error) {
        console.error("Error calling Anthropic API:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Error calling API: " + error.message,
        );
      }
    });

exports.fetchDailyNews = functions.pubsub.schedule("0 0 * * *")
    .timeZone("America/New_York")
    .onRun(async (context) => {
      const apiKey = functions.config().newsdata.api_key;
      const url = `https://newsdata.io/api/1/news?apikey=${apiKey}&q=weight%20loss%20glp&language=en`;

      try {
        const response = await axios.get(url);
        const articles = response.data.results;

        const batch = admin.firestore().batch();
        const newsRef = admin.firestore().collection("news");

        // Delete existing articles
        const existingArticles = await newsRef.get();
        existingArticles.forEach((doc) => {
          batch.delete(doc.ref);
        });

        // Add new articles
        articles.forEach((article) => {
          const docRef = newsRef.doc();
          batch.set(docRef, {
            title: article.title || "",
            description: article.description || "",
            url: article.link || "",
            imageUrl: article.image_url || "",
            pubDate: article.pubDate || "",
            author: Array.isArray(article.creator) ?
            article.creator.join(", ") : (article.creator || "Unknown"),
            publisher: article.source_id || "",
            country: Array.isArray(article.country) ?
            article.country.join(", ") : (article.country || "Unknown"),
            category: Array.isArray(article.category) ?
          article.category.join(", ") : (article.category || "Unknown"),
            language: article.language || "",
          });
        });

        await batch.commit();
        console.log("News articles updated successfully");
        return null;
      } catch (error) {
        console.error("Error fetching news:", error);
        return null;
      }
    });
