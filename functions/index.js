const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Function to send chat notification
exports.sendChatNotification = functions.firestore
    .document('chat_history/{userId1}/{userId2}/{messageId}')
    .onCreate(async (snapshot, context) => {
        const messageData = snapshot.data();

        // The sender should not receive a notification
        if (messageData.senderId === context.params.userId1) {
            return null;
        }

        // Fetch the sender's display name
        const senderName = await getSenderName(messageData.senderId);

        // Determine the recipient's ID (the one who is not the sender)
        const recipientId = messageData.senderId === context.params.userId1
            ? context.params.userId2 : context.params.userId1;

        // Fetch the recipient's FCM token
        const recipientToken = await getRecipientToken(recipientId);

        // If no token is found, exit
        if (!recipientToken) {
            console.log('No FCM token for recipient:', recipientId);
            return null;
        }

        const payload = {
            notification: {
                title: `${senderName} Says`, 
                body: messageData.text,
            },
            token: recipientToken,
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

async function getSenderName(senderId) {
    try {
        const senderDoc = await admin.firestore().collection('users').doc(senderId).get();
        return senderDoc.data()?.displayName || 'Unknown Sender'; // Default to 'Unknown Sender' if name not found
    } catch (error) {
        console.log('Error fetching sender name:', error);
        return 'Unknown Sender';
    }
}

async function getRecipientToken(recipientId) {
    try {
        const userDoc = await admin.firestore().collection('users').doc(recipientId).get();
        return userDoc.data()?.fcmToken;
    } catch (error) {
        console.log('Error fetching recipient token:', error);
        return null;
    }
}

// Function to initialize unreadMessagesCount for new users
exports.createUserProfile = functions.auth.user().onCreate((user) => {
    return admin.firestore().collection('users').doc(user.uid).set({
        // Set other initial user profile values as needed
        unreadMessagesCount: 0
    }, { merge: true });
});