import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/theme/app_theme.dart';
import 'package:mobile_application/widgets/auth_shell.dart';
import 'package:mobile_application/widgets/customButton.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isSendingVerification = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _sendVerificationEmail());
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      isSendingVerification = true;
    });

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final result = await authViewModel.sendVerificationEmail();

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending verification email: ${result.errorMessage}")),
      );
    }

    setState(() {
      isSendingVerification = false;
    });
  }

  Future<void> _checkVerification() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    bool verified = await authViewModel.checkEmailVerification();

    if (verified) {
      Navigator.pushReplacementNamed(context, '/mainUi/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not verified yet. Please check your inbox.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: "Email Verification",
      subtitle: "Complete account activation before entering Panel Control",
      child: Column(
        children: [
          const Text(
            "A verification email has been sent to your email address. Please check your inbox and click the verification link.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: isSendingVerification ? "Sending..." : "Resend Verification Email",
            onPressed: isSendingVerification ? () {} : _sendVerificationEmail,
            backgroundColor: AppTheme.secondary,
            textColor: Colors.white,
          ),
          const SizedBox(height: 14),
          CustomButton(
            text: "I've Verified, Continue",
            onPressed: _checkVerification,
          ),
        ],
      ),
    );
  }
}