import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/theme/app_theme.dart';
import 'package:mobile_application/widgets/auth_shell.dart';
import 'package:mobile_application/widgets/customButton.dart';
import 'package:mobile_application/widgets/customTextField.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';

class PasswordResetEmailScreen extends StatefulWidget {
  const PasswordResetEmailScreen({super.key});

  @override
  _PasswordResetEmailScreenState createState() => _PasswordResetEmailScreenState();
}

class _PasswordResetEmailScreenState extends State<PasswordResetEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendResetLink() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError("Please enter your email address");
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final result = await authViewModel.sendPasswordResetEmail(email);

    if (result.isSuccess) {
      _showSnackbar("Password reset link sent to $email. Please check your inbox.");
      Future.delayed(const Duration(seconds: 4), () {
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
    return AuthShell(
      title: "Reset Password",
      child: Column(
        children: [
          const Text(
            "Enter the email address for which you want to reset the password.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: _emailController,
            hintText: "Email",
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _sendResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.bgDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Send Reset Link",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          CustomButton(
            text: "Back to Login",
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/logIn/');
            },
            backgroundColor: AppTheme.secondary,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}