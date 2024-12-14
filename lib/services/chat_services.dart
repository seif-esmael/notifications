import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:notifications/services/user_services.dart';

class ChatServices {
    static Future<void> sendMessageRealtime(String channelId, String message) async {
    try {
      final userId = await UserServices.getUserId();
      final userName = await UserServices.getUserName();

      if (userId == null) {
        print('Error: Could not retrieve user ID for message.');
        return;
      }

      final messageRef = FirebaseDatabase.instance
          .ref('channels/$channelId/messages')
          .push();

      final timestamp = DateTime.now().toIso8601String();
      await messageRef.set({
        'message': message,
        'timestamp': timestamp,
        'userId': userId,
        'userName': userName ?? 'Anonymous',
      });

      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  static void listenForMessagesRealtime(String channelId) {
    DatabaseReference channelRef =
        FirebaseDatabase.instance.ref('channels/$channelId/messages');

    channelRef.onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> messageData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        print('New message in channel $channelId: $messageData');
      }
    });
  }

  static Future<void> sendMessageFireStore(String channelId, String message) async {
    try {
      final userId = await UserServices.getUserId();
      final userName = await UserServices.getUserName();

      if (userId == null) {
        print('Error: Could not retrieve user ID for message.');
        return;
      }

      await FirebaseFirestore.instance
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .add({
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        'userName': userName ?? 'Anonymous',
      });

      print('Message sent to channel $channelId: $message');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  static void listenForMessagesFireStore(String channelId) {
    FirebaseFirestore.instance
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        print('New message in channel $channelId: ${doc.data()}');
      }
    });
  }
}