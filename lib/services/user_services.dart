import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications/firebase_options.dart';
import 'package:notifications/models/user.dart';

class UserServices {
  static Future<String?> getDeviceToken() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        print('Device Token: $token');
      } else {
        print('Failed to get device token.');
      }

      return token;
    } catch (e) {
      print('Error retrieving device token: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

  static Future<void> addUser(UserData user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        ...user.toJson(),
        'isFirstTime': true,
      });
      print('User added successfully');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  static Future<void> saveDeviceTokenToDB() async {
    try {
      String? token = await getDeviceToken();
      if (token == null || token.isEmpty) {
        print('Error: Failed to retrieve device token');
        return;
      }

      DatabaseReference tokensRef = FirebaseDatabase.instance.ref('users/tokens');
      DatabaseEvent event = await tokensRef.orderByChild('token').equalTo(token).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        print('Token already exists in the database');
      } else {
        await tokensRef.push().set({
          'token': token,
          'createdAt': DateTime.now().toIso8601String(),
        });
        print('Token added to database');
      }
    } catch (e) {
      print('Error adding token to database: $e');
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      return user?.email;
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  static Future<String?> getUserId() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      return user?.uid;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  static Future<String> getUserName() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user is signed in');
        return 'null';
      }

      final displayName = user.displayName;

      if (displayName != null && displayName.isNotEmpty) {
        return displayName;
      }
      final userData = await getUserData(user.uid);
      if (userData != null && userData.containsKey('userName')) {
        return userData['userName'];
      }

      print('User name not found');
      return 'null';
    } catch (e) {
      print('Error retrieving user name: $e');
      return 'null';
    }
  }


  static Future<bool> isFirstTimeLogin(String userId) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['isFirstTime'] ?? false;
      }
      print('User document does not exist or is missing data.');
      return false;
    } catch (e) {
      print('Error checking first-time login: $e');
      return false;
    }
  }

    static Future<void> storeFirstLoginTime(String userId) async {
    try {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref('first_time_login_logs/$userId');
      final DataSnapshot snapshot = await userRef.child('firstLoginTime').get();
      if (!snapshot.exists) {
        await userRef.update({
          'firstLoginTime': DateTime.now().toIso8601String(),
        });
        print('First login time recorded successfully.');
      } else {
        print('First login time already exists.');
      }
    } catch (e) {
      print('Error storing first login time: $e');
    }
  }


  static Future<void> updateIsFirstTime(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isFirstTime': false});
      print('isFirstTime updated to false.');
    } catch (e) {
      print('Error updating isFirstTime: $e');
    }
  }
}
