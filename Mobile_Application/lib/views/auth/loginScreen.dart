import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/utils/constants.dart';
import 'package:mobile_application/widgets/customButton.dart';
import 'package:mobile_application/widgets/customTextField.dart';
import 'package:mobile_application/providers/theme_provider.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key
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
      // Get the AuthViewModel from Provider
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      // Call the login method from the ViewModel
      final result = await authViewModel.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Based on the result, navigate accordingly
      if (result.isSuccess) {
        if (result.userEmailVerified) {
          Navigator.pushReplacementNamed(context, '/loading/');
        } else {
          Navigator.pushReplacementNamed(context, '/emailVerification/');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage),
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
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF212121) : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Sign In",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.white,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF4527A0) : Colors.deepPurple,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212121),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/panel.jpg',
                  height: 250,
                  width: 250,
                ),
                const SizedBox(height: 5),
                Text(
                  AppConstants.welcomeMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212121),
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: "Enter Your Email",
                  controller: _emailController,
                  hintColor: themeProvider.isDarkMode ? (Colors.grey[400] ?? Colors.grey) : (Colors.grey[700] ?? Colors.grey),
                  textColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFF212121),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
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
                  hintColor: themeProvider.isDarkMode ? (Colors.grey[400] ?? Colors.grey) : (Colors.grey[700] ?? Colors.grey),
                  textColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFF212121),
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
                    icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
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
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.blue[300] : Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Sign In",
                  onPressed: _validateAndLogin, // Call Firebase sign-in and navigation logic
                  backgroundColor: themeProvider.isDarkMode ? const Color(0xFF4527A0) : const Color(0xFF7E57C2),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New to the management team? ",
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212121),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Clear login credentials before navigating to sign up
                        _emailController.clear();
                        _passwordController.clear();
                        Navigator.pushNamed(context, '/signUp/');
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.blue[300] : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}