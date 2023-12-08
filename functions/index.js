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
                title: `New message from ${messageData.senderId}`, // Customize as needed
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

async function getRecipientToken(recipientId) {
    try {
        const userDoc = await admin.firestore().collection('users').doc(recipientId).get();
        return userDoc.data()?.fcmToken;
    } catch (error) {
        console.log('Error fetching recipient token:', error);
        return null;
    }
}

// Function to increment unread message count
exports.incrementUnreadCount = functions.firestore
    .document('chat_history/{userId1}/{userId2}/{messageId}')
    .onCreate((snapshot, context) => {
        const messageData = snapshot.data();

        // Skip if the message sender is viewing their own message
        if (messageData.senderId === context.params.userId1) {
            return null;
        }

        const recipientId = messageData.senderId === context.params.userId1
            ? context.params.userId2 : context.params.userId1;

        return admin.firestore().collection('users').doc(recipientId)
            .update({ unreadMessagesCount: admin.firestore.FieldValue.increment(1) });
    });

// Function to decrement unread message count
exports.markMessageAsRead = functions.firestore
    .document('chat_history/{userId}/{chatId}/{messageId}')
    .onUpdate((change, context) => {
        const newValue = change.after.data();
        const previousValue = change.before.data();

        if (!previousValue.read && newValue.read) {
            // Message was marked as read
            return admin.firestore().collection('users').doc(context.params.userId)
                .update({ unreadMessagesCount: admin.firestore.FieldValue.increment(-1) });
        } else {
            return null;
        }
    });

// Function to initialize unreadMessagesCount for new users
exports.createUserProfile = functions.auth.user().onCreate((user) => {
    return admin.firestore().collection('users').doc(user.uid).set({
        // Set other initial user profile values as needed
        unreadMessagesCount: 0
    }, { merge: true });
});