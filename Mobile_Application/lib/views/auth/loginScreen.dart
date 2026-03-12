import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/theme/app_theme.dart';
import 'package:mobile_application/utils/constants.dart';
import 'package:mobile_application/widgets/auth_shell.dart';
import 'package:mobile_application/widgets/customButton.dart';
import 'package:mobile_application/widgets/customTextField.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  Future<void> _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      final result = await authViewModel.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result.isSuccess) {
        if (result.userEmailVerified) {
          Navigator.pushReplacementNamed(context, '/loading/');
        } else {
          Navigator.pushReplacementNamed(context, '/emailVerification/');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: "Sign In",
      subtitle: AppConstants.welcomeMessage,
      showBackButton: false,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 22),
            CustomTextField(
              hintText: "Enter Your Email",
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                if (!RegExp(
                  r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                ).hasMatch(value)) {
                  return "Enter a valid email address";
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            CustomTextField(
              hintText: "Enter Your Password",
              controller: _passwordController,
              obscureText: !passwordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password is required";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters long";
                }
                return null;
              },
              suffixIcon: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.muted,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/management/');
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: "Sign In",
              onPressed: _validateAndLogin,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Not already registered? ",
                  style: TextStyle(color: AppTheme.muted),
                ),
                TextButton(
                  onPressed: () {
                    _emailController.clear();
                    _passwordController.clear();
                    Navigator.pushNamed(context, '/signUp/');
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}