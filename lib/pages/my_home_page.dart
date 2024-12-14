import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notifications/screens/channels_screen.dart';
import 'package:notifications/services/auth.dart';
import 'package:notifications/models/user.dart';
import 'package:notifications/customs/custom_button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final firebase_auth.User? firebaseUser = Auth().currentUser;
  UserData? customUser;

  Future<void> _signOut() async {
    await Auth().signout();
  }

  Future<void> _getUserData() async {
    if (firebaseUser != null) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser!.uid)
            .get();
        if (docSnapshot.exists) {
          setState(() {
            customUser = UserData.fromJson(docSnapshot.data()!);
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData(); // Fetch user data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user has a Google displayName
    String displayName = firebaseUser?.displayName ?? customUser?.userName ?? "User";

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          "Youtuksh",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // User Icon
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueGrey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  // Display Name (fetch from Firestore or Google)
                  Text(
                        displayName,
                          style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        ),

                  // Display Email
                  Text(
                    firebaseUser!.email.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Go to channels Button
                  CustomButton(
                    content: "Go to Channels",
                    onTap: () {
                      Navigator.of(context).pushNamed(ChannelsScreen.channelsRoute);
                    },
                  ),

                  const SizedBox(height: 30),

                  // Sign-out Button
                  CustomButton(
                    content: "Sign Out",
                    onTap: () {
                      _signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
