import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/widgets/customButton.dart';
import 'package:mobile_application/widgets/customTextField.dart';
import 'package:mobile_application/providers/theme_provider.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  //Controllers to retrieve user inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _managementPasswordController = TextEditingController();

  // Email validation function
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required.";
    }
    // Basic email validation pattern
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address.";
    }
    return null;
  }

  // Password validation function
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required.";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters long.";
    }
    return null;
  }

  // Confirm Password validation function
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password.";
    }
    if (value != _passwordController.text) {
      return "Passwords do not match.";
    }
    return null;
  }

  // Management Password validation function
  String? _validateManagementPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Management password is required.";
    }
    if (value != "MANAGER2025") {
      return "Incorrect management code.";
    }
    return null;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      // Get the AuthViewModel from Provider
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      // Call the signUp method from the ViewModel
      final result = await authViewModel.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _managementPasswordController.text.trim(),
      );

      // Based on the result, show a message or navigate accordingly
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account created successfully!"),
            duration: Duration(seconds: 2),
          ),

        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
        // Optionally, navigate to a different page after sign up
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${result.errorMessage}"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sign Up",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.white,
          ),
        ),
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF4527A0) : Colors.deepPurple,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.white,
        ),
        elevation: 0,
      ),
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF212121) : Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey, // Assign form key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  hintText: "Email",
                  validator: _validateEmail,
                  hintColor: themeProvider.isDarkMode ? (Colors.grey[400] ?? Colors.grey) : (Colors.grey[700] ?? Colors.grey),
                  // Change textColor to black in dark mode for better contrast
                  textColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFF212121),
                ),
                const SizedBox(height: 15),
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  obscureText: true,
                  validator: _validatePassword,
                  hintColor: themeProvider.isDarkMode ? (Colors.grey[400] ?? Colors.grey) : (Colors.grey[700] ?? Colors.grey),
                  textColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFF212121),
                ),
                const SizedBox(height: 15),
                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                  validator: _validateConfirmPassword,
                  hintColor: themeProvider.isDarkMode ? (Colors.grey[400] ?? Colors.grey) : (Colors.grey[700] ?? Colors.grey),
                  textColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFF212121),
                ),
                const SizedBox(height: 30),
                // Management Password Field
                CustomTextField(
                  controller: _managementPasswordController,
                  hintText: "Management Password",
                  obscureText: true,
                  validator: _validateManagementPassword,
                  hintColor: themeProvider.isDarkMode ? (Colors.grey[400] ?? Colors.grey) : (Colors.grey[700] ?? Colors.grey),
                  textColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFF212121),
                ),
                const SizedBox(height: 30),
                // Already have an account? Sign in option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212121),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/logIn/');
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.blue[300] : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                // Sign Up Button
                CustomButton(
                  text: "Create Account",
                  onPressed: _signUp, // Validate form on button press and create user in Firebase
                  backgroundColor: themeProvider.isDarkMode ? const Color(0xFF4527A0) : Color(0xFF7E57C2),
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
