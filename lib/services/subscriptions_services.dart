import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications/services/analytics_service.dart';
import 'package:notifications/services/user_services.dart';

class SubscriptionServices {
  static List<String> subscribed_channels = [];

  static Future<void> subscribeToChannelRealTimeDB(String channel) async {
    print(subscribed_channels);
    if (!subscribed_channels.contains(channel)) {
      String? uid = await UserServices.getUserId();
      String userName = await UserServices.getUserName();
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref('subscriptions/users/$uid');
      await userRef.update({
        channel: true,
      });

      subscribed_channels.add(channel);
      await FirebaseMessaging.instance.subscribeToTopic(channel);
      await AnalyticsServices.subscribe(channel, userName);
      print('Subscribed to $channel');
    } else {
      print('Already subscribed to $channel');
    }
  }

  static Future<void> unsubscribeFromChannelRealTimeDB(String channel) async {
    print(subscribed_channels);
    if (subscribed_channels.contains(channel)) {
      String? uid = await UserServices.getUserId();
      String userName = await UserServices.getUserName();
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref('subscriptions/users/$uid');
      userRef.child(channel).remove();

      await FirebaseMessaging.instance.unsubscribeFromTopic(channel);
      await AnalyticsServices.unsubscribe(channel, userName);
      subscribed_channels.remove(channel);
      print('Unsubscribed from $channel');
    } else {
      print('Not subscribed to $channel');
    }
  }

  static Future<void> subscribeToChannelFirestore(
      String userId, String channelId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .doc(channelId)
          .set({
        'subscribedAt': FieldValue.serverTimestamp(),
      });
      print('User $userId subscribed to $channelId');
    } catch (e) {
      print('Error subscribing to channel: $e');
    }
  }

  static Future<void> unsubscribeFromChannelFireStore(
      String userId, String channelId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .doc(channelId)
          .delete();
      print('User $userId unsubscribed from $channelId');
    } catch (e) {
      print('Error unsubscribing from channel: $e');
    }
  }
}
