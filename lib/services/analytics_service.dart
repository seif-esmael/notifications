import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsServices {
  static Future<void> register(String username, String method) async {
    await FirebaseAnalytics.instance.logSignUp(
      signUpMethod: method,
      parameters: {
        'username': username,
      },
    ).then((value) => print("User ${username} registered in the Application"));
  }

  static Future<void> login(String username, String method) async {
    print("Executing login analytics for user: $username, method: $method");
    try {
      await FirebaseAnalytics.instance.logLogin(
        loginMethod: method,
        parameters: {
          'username': username,
        },
      );
      print("User $username logged in the Application for the first time");
    } catch (e) {
      print("Failed to log login analytics: $e");
    }
  }

  static Future<void> subscribe(String channelName, String userName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'Subscribe_Channel',
      parameters: {
        'channel_id': channelName,
        'userName': userName,
      },
    ).then((value) => print("User ${userName} subscribed to the channel"));
  }

  static Future<void> unsubscribe(String channelName, String userName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'Unsubscribe_Channel',
      parameters: {
        'channel_id': channelName,
        'userName': userName,
      },
    ).then((value) => print("User ${userName} unsubscribed from the channel"));
  }
}
