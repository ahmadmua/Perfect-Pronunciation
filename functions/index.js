const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.verifyIP = functions.https.onRequest(async (req, res) => {
    const userId = req.query.uid;
    const currentIP = req.query.ip;

    if (!userId || !currentIP) {
        return res.status(400).send("Invalid parameters.");
    }

    try {
        const userRef = db.collection("UserData").doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            return res.status(404).send("User not found.");
        }

        const data = userDoc.data();
        const trustedIPs = data.IP || [];

        // Check if the IP is already trusted
        if (trustedIPs.includes(currentIP)) {
            return res.status(200).send("IP is already trusted.");
        }

        // Add the new IP to the list
        trustedIPs.push(currentIP);
        await userRef.update({ IP: trustedIPs });

        return res.status(200).send("IP added to trusted list. You may now log in.");
    } catch (error) {
        console.error("Error verifying IP:", error);
        return res.status(500).send("Failed to verify IP. Please try again later.");
    }
});
