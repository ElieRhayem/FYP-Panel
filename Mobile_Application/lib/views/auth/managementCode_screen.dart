import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/core/theme/app_theme.dart';
import 'package:mobile_application/widgets/auth_shell.dart';
import 'package:mobile_application/widgets/customButton.dart';
import 'package:mobile_application/widgets/customTextField.dart';

class ManagementCodeScreen extends StatefulWidget {
  const ManagementCodeScreen({super.key});

  @override
  _ManagementCodeScreenState createState() => _ManagementCodeScreenState();
}

class _ManagementCodeScreenState extends State<ManagementCodeScreen> {
  final TextEditingController _managementCodeController = TextEditingController();
  final String _predefinedManagementCode = "MANAGER2026";
  int _attempts = 0;

  @override
  void dispose() {
    _managementCodeController.dispose();
    super.dispose();
  }

  void _verifyManagementCode() {
    final enteredCode = _managementCodeController.text.trim();

    if (enteredCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the management code")),
      );
      return;
    }

    if (enteredCode == _predefinedManagementCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Management code verified.")),
      );
      Navigator.pushReplacementNamed(context, '/resetPass/');
    } else {
      _attempts++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect management code. Please try again.")),
      );

      if (_attempts >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Too many incorrect attempts. The app will close now."),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          SystemNavigator.pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: "Password Reset",
      subtitle: "Enter the management code to continue",
      child: Column(
        children: [
          const SizedBox(height: 18),
          CustomTextField(
            controller: _managementCodeController,
            hintText: "Management Code",
            obscureText: true,
          ),
          const SizedBox(height: 18),
          CustomButton(
            text: "Proceed",
            onPressed: _verifyManagementCode,
          ),
        ],
      ),
    );
  }
}