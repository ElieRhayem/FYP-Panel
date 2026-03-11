import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/widgets/customTextField.dart';
import 'package:mobile_application/providers/theme_provider.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';

class PasswordResetEmailScreen extends StatefulWidget {
  @override
  _PasswordResetEmailScreenState createState() =>
      _PasswordResetEmailScreenState();
}

class _PasswordResetEmailScreenState extends State<PasswordResetEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isProcessing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Helper function to show error messages
  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper function to show success messages
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendResetLink() async {
    final String email = _emailController.text.trim();

    // Validate email input
    if (email.isEmpty) {
      _showError("Please enter your email address");
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Get the AuthViewModel from Provider and call its method
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final result = await authViewModel.sendPasswordResetEmail(email);

    if (result.isSuccess) {
      _showSnackbar(
        "Password reset link sent to $email. Please check your inbox.",
      );
      Future.delayed(Duration(seconds: 4), () {
        Navigator.pushReplacementNamed(context, '/logIn/');
      });
    } else {
      _showError("Error: ${result.errorMessage}");
    }

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Reset Password",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            themeProvider.isDarkMode
                ? const Color(0xFF4527A0)
                : Colors.deepPurple,
        elevation: 0,
      ),
      backgroundColor:
          themeProvider.isDarkMode ? const Color(0xFF212121) : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Enter the email address for which you want to reset the password.",
                style: TextStyle(
                  fontSize: 16,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : const Color(0xFF212121),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _emailController,
                hintText: "Email",
                hintColor:
                    themeProvider.isDarkMode
                        ? (Colors.grey[400] ?? Colors.grey)
                        : (Colors.grey[700] ?? Colors.grey),
                textColor:
                    themeProvider.isDarkMode
                        ? Colors.black
                        : const Color(0xFF212121),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isProcessing ? null : _sendResetLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeProvider.isDarkMode
                          ? const Color(0xFF4527A0)
                          : const Color(0xFF7E57C2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child:
                    _isProcessing
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          "Send Reset Link",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/logIn/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeProvider.isDarkMode
                          ? const Color(0xFF4527A0)
                          : const Color(0xFF7E57C2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: Text(
                  "Back to Login",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
