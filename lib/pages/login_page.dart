import 'package:flutter/material.dart';
import 'package:notifications/customs/custom_button.dart';
import 'package:notifications/customs/custom_textfield.dart';
import 'package:notifications/services/analytics_service.dart';
import 'package:notifications/services/auth.dart';
import 'package:notifications/models/user.dart';
import 'package:notifications/services/user_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _loginWithEmailAndPassword() async {
    try {
      final userId = await Auth().signinWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (userId != null) {
        final isFirstTime = await UserServices.isFirstTimeLogin(userId);
        final userData = await UserServices.getUserData(userId);

        if (userData != null) {
          final user = UserData.fromJson(userData);
          if (isFirstTime) {
            await UserServices.updateIsFirstTime(userId);
            await UserServices.storeFirstLoginTime(userId);
            await AnalyticsServices.login(_emailController.text, 'Email');
            print("Analytics login function executed");
            _showWelcomeDialog(user);
            return;
          }
          Navigator.of(context).pushReplacementNamed('/home', arguments: user);
        } else {
          setState(() {
            errorMessage = 'User data not found.';
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _loginWithGoogle() async {
    try {
      final user = await Auth().signInWithGoogle();
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home', arguments: user);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _showWelcomeDialog(UserData user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welcome!'),
        content: const Text(
            'Thank you for logging in for the first time! We hope you enjoy the experience.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed('/home', arguments: user);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // Page logo
                  const Icon(
                    Icons.lock,
                    size: 50,
                  ),
                  const SizedBox(height: 50),

                  // Welcome message
                  const Text(
                    "Welcome To Notifications And Chatting System",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 50),

                  // Email field
                  CustomTextField(
                    key: const Key('emailField'),
                    controller: _emailController,
                    hint: 'Email Address',
                    obsecuretext: false,
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  CustomTextField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    hint: 'Password',
                    obsecuretext: !isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign In button
                  CustomButton(
                    key: const Key('signInButton'),
                    content: "Sign In",
                    onTap: _loginWithEmailAndPassword,
                  ),
                  const SizedBox(height: 20),

                  if (errorMessage != null && errorMessage!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const Text("Or login with"),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _loginWithGoogle,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          backgroundColor: Colors.white,
                        ),
                        child: Image.asset(
                          'images/google.png',
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/phone-auth');
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                        ),
                        child: const Icon(
                          Icons.phone,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  const Text("You don't have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: const Text(
                      "Register now",
                      style: TextStyle(color: Colors.lightBlue),
                    ),
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
