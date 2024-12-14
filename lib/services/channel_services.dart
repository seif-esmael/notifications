import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications/services/subscriptions_services.dart';

class ChannelServices {

  static Future<void> addChannelFireStore(String channelId) async {
    try {
      await FirebaseFirestore.instance
          .collection('channels')
          .doc(channelId)
          .set({
        'name': channelId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Channel $channelId added to Firestore');
    } catch (e) {
      print('Error adding channel: $e');
    }
  }

  static Stream<List<String>> getChannels() {
    return FirebaseFirestore.instance
        .collection('channels')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  static Future<void> deleteChannelFireStore(String channelId) async {
    try {
      await FirebaseFirestore.instance
          .collection('channels')
          .doc(channelId)
          .delete();
      print('Channel "$channelId" deleted successfully.');
      if (SubscriptionServices.subscribed_channels.contains(channelId)) {
        SubscriptionServices.subscribed_channels.remove(channelId);
        await FirebaseMessaging.instance.unsubscribeFromTopic(channelId);
        print('Unsubscribed from $channelId');
      }
    } catch (e) {
      print('Error deleting channel: $e');
    }
  }

  static Future<void> deleteChannelRealtime(String channelId) async {
    try {
      DatabaseReference channelRef =
          FirebaseDatabase.instance.ref('channels/$channelId');
      await channelRef.remove();
      print(
          'Channel "$channelId" deleted successfully from Realtime Database.');
      if (SubscriptionServices.subscribed_channels.contains(channelId)) {
        SubscriptionServices.subscribed_channels.remove(channelId);
        await FirebaseMessaging.instance.unsubscribeFromTopic(channelId);
        print('Unsubscribed from $channelId.');
      }
    } catch (e) {
      print('Error deleting channel from Realtime Database: $e');
    }
  }
}