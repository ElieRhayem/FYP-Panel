import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/theme/app_theme.dart';
import 'package:mobile_application/widgets/auth_shell.dart';
import 'package:mobile_application/widgets/customButton.dart';
import 'package:mobile_application/widgets/customTextField.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _managementPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _managementVisible = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required.";
    }
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address.";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required.";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters long.";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password.";
    }
    if (value != _passwordController.text) {
      return "Passwords do not match.";
    }
    return null;
  }

  String? _validateManagementPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Management password is required.";
    }
    if (value != "MANAGER2026") {
      return "Incorrect management code.";
    }
    return null;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      final result = await authViewModel.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _managementPasswordController.text.trim(),
      );

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${result.errorMessage}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: "Sign Up",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              hintText: "Email",
              validator: _validateEmail,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _passwordController,
              hintText: "Password",
              obscureText: !_passwordVisible,
              validator: _validatePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.muted,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: "Confirm Password",
              obscureText: !_confirmPasswordVisible,
              validator: _validateConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.muted,
                ),
                onPressed: () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _managementPasswordController,
              hintText: "Management Password",
              obscureText: !_managementVisible,
              validator: _validateManagementPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _managementVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.muted,
                ),
                onPressed: () {
                  setState(() {
                    _managementVisible = !_managementVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: AppTheme.muted),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/logIn/');
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: "Create Account",
              onPressed: _signUp,
            ),
          ],
        ),
      ),
    );
  }
}