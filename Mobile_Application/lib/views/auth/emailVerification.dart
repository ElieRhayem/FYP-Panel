import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/providers/theme_provider.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';

class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isSendingVerification = false;

  @override
  void initState() {
    super.initState();
    // Automatically send the verification email after build is complete.
    Future.microtask(() => _sendVerificationEmail());
  }

  // Delegates the action to the ViewModel.
  Future<void> _sendVerificationEmail() async {
    setState(() {
      isSendingVerification = true;
    });
    // Get the AuthViewModel instance.
    final authViewModel =
    Provider.of<AuthViewModel>(context, listen: false);
    final result = await authViewModel.sendVerificationEmail();

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification email sent!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error sending verification email: ${result.errorMessage}")),
      );
    }

    setState(() {
      isSendingVerification = false;
    });
  }

  // Delegates checking the email verification status to the ViewModel.
  Future<void> _checkVerification() async {
    final authViewModel =
    Provider.of<AuthViewModel>(context, listen: false);
    bool verified = await authViewModel.checkEmailVerification();
    if (verified) {
      Navigator.pushReplacementNamed(context, '/mainUi/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email not verified yet. Please check your inbox.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Email Verification",
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF4527A0) : Colors.deepPurple,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.white,
        ),
        elevation: 0,
      ),
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF212121) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "A verification email has been sent to your email address. Please check your inbox and click on the verification link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isSendingVerification ? null : _sendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.isDarkMode
                      ? const Color(0xFF4527A0)
                      : Colors.deepPurple,
                ),
                child: Text(
                  isSendingVerification ? "Sending..." : "Resend Verification Email",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.isDarkMode
                      ? const Color(0xFF4527A0)
                      : Colors.deepPurple,
                ),
                child: const Text(
                  "I've Verified, Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
