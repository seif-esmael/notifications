import 'package:flutter/material.dart';
import 'package:notifications/services/analytics_service.dart';
import 'package:notifications/services/auth.dart';
import 'package:notifications/customs/custom_textfield.dart';
import 'package:notifications/customs/custom_button.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  bool _isOTPRequested = false;
  String? errorMessage;

  void _sendCode() async {
    try {
      await Auth().signInWithPhoneNumber(
        _phoneController.text,
        (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isOTPRequested = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = "Failed to send OTP. Please try again.";
      });
    }
  }

  void _verifyOtp() async {
    try {
      await Auth().verifyOtp(_verificationId!, _otpController.text);
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() {
        errorMessage = "Invalid OTP. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Consistent background color
      appBar: AppBar(
        title: const Text('Phone Authentication'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Phone Authentication",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Error Message
                if (errorMessage != null && errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Phone Number Input
                CustomTextField(
                  controller: _phoneController,
                  hint: 'Phone Number',
                  obsecuretext: false,
                ),
                const SizedBox(height: 20),

                // OTP Input (Visible only if OTP is requested)
                if (_isOTPRequested)
                  CustomTextField(
                    controller: _otpController,
                    hint: 'Enter OTP',
                    obsecuretext: false,
                  ),
                const SizedBox(height: 20),

                // Action Button (Send OTP / Verify OTP)
                CustomButton(
                  content: _isOTPRequested ? 'Verify OTP' : 'Send OTP',
                  onTap: _isOTPRequested ? _verifyOtp : _sendCode,
                ),
                const SizedBox(height: 20),

                // Back to Login Button (Visible only if OTP is not requested)
                if (!_isOTPRequested)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
