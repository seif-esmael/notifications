import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notifications/firebase_options.dart';
import 'package:notifications/pages/login_page.dart';
import 'package:notifications/pages/my_home_page.dart';
import 'package:notifications/pages/phone_auth.dart';
import 'package:notifications/screens/channels_screen.dart';
import 'package:notifications/services/notification_services.dart';
import 'package:notifications/services/user_services.dart';

import 'pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await NotificationServices.initNotifications();
  await UserServices.saveDeviceTokenToDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        ChannelsScreen.channelsRoute: (context) => const ChannelsScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MyHomePage(),
        '/phone-auth' :(context) => const PhoneAuth(),
      },
    );
  }
}
