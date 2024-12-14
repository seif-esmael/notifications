import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications/firebase_options.dart';

class NotificationServices {
  static void foregroundNotificationHandler(RemoteMessage message) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      DatabaseReference messageRef =
          FirebaseDatabase.instance.ref("foreground");
      await messageRef.push().set({
        'title': message.notification?.title,
        'body': message.notification?.body,
        'date': message.sentTime?.toString(),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> backgroundNotificationHandler(
      RemoteMessage message) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      DatabaseReference messageRef =
          FirebaseDatabase.instance.ref("background");
      await messageRef.push().set({
        'title': message.notification?.title,
        'body': message.notification?.body,
        'date': message.sentTime?.toString(),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> initNotifications() async {
    FirebaseMessaging.onBackgroundMessage(backgroundNotificationHandler);
    FirebaseMessaging.onMessage.listen(foregroundNotificationHandler);
  }
}