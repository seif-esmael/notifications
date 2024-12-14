import 'package:flutter/material.dart';
import 'package:notifications/customs/custom_button.dart';
import 'package:notifications/customs/custom_textfield.dart';
import 'package:notifications/services/analytics_service.dart';
import 'package:notifications/services/auth.dart';
import 'package:notifications/services/user_services.dart';
import 'package:notifications/models/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  void _register() async {
    try {
      final userId = await Auth().createWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userId != null) {
        final user = UserData(
          id: userId,
          userName: _userNameController.text,
          email: _emailController.text,
          phoneNumber: '',
        );

        await UserServices.addUser(user);
        Navigator.of(context).pushReplacementNamed('/login');
        await AnalyticsServices.register(_userNameController.text, 'Email');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal:
                    20.0), // Add padding to avoid text field touching edges
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
                const Text("Create a new account",
                    style: TextStyle(fontSize: 20)),
                const SizedBox(height: 50),

                // Username field
                CustomTextField(
                  controller: _userNameController,
                  hint: 'Username',
                  obsecuretext: false,
                ),
                const SizedBox(height: 20),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  hint: 'Email Address',
                  obsecuretext: false,
                ),
                const SizedBox(height: 20),

                // Password field with eye icon for toggle
                CustomTextField(
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

                // Register button
                CustomButton(
                  content: "Register",
                  onTap: _register,
                ),
                const SizedBox(height: 20),

                const Text("Already have an account?"),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/login');
                  },
                  child: const Text(
                    "Login now",
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
