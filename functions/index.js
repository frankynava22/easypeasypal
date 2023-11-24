const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendChatNotification = functions.firestore
    .document('chat_history/{userId}/{chatId}/{messageId}')
    .onCreate(async (snapshot, context) => {
        const messageData = snapshot.data();

        // Do not send a notification if the sender is the recipient
        if (messageData.senderId === context.params.userId) {
            return null;
        }

        // Fetch the recipient's FCM token or user info to send a notification
        // Assuming you have a way to get the recipient's FCM token
        const recipientId = context.params.userId; // or derive from your data model
        const recipientToken = await getRecipientToken(recipientId);

        const payload = {
            notification: {
                title: `New message`,
                body: messageData.text,
                // other notification options
            },
            token: recipientToken, // FCM token of the recipient
        };

        return admin.messaging().send(payload)
            .then(response => {
                console.log('Notification sent successfully:', response);
                return null;
            })
            .catch(error => {
                console.log('Error sending notification:', error);
            });
    });

async function getRecipientToken(userId) {
    // Function to retrieve the recipient's FCM token
    // Implement logic to fetch token from Firestore or your user model
    // Example:
    // const userDoc = await admin.firestore().collection('users').doc(userId).get();
    // return userDoc.data().fcmToken;
}
