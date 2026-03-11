import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/providers/theme_provider.dart';
import 'package:mobile_application/widgets/customTextField.dart';

class ManagementCodeScreen extends StatefulWidget {
  @override
  _ManagementCodeScreenState createState() => _ManagementCodeScreenState();
}

class _ManagementCodeScreenState extends State<ManagementCodeScreen> {
  final TextEditingController _managementCodeController =
      TextEditingController();

  // Predefined management code.
  final String _predefinedManagementCode = "MANAGER2025";

  int _attempts = 0; // Counter for incorrect attempts

  @override
  void dispose() {
    _managementCodeController.dispose();
    super.dispose();
  }

  void _verifyManagementCode() {
    final enteredCode = _managementCodeController.text.trim();
    if (enteredCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the management code")),
      );
      return;
    }
    if (enteredCode == _predefinedManagementCode) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Management code verified.")));
      // Navigate to the page where the user enters their email.
      Navigator.pushReplacementNamed(context, '/resetPass/');
    } else {
      _attempts++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Incorrect management code. Please try again.")),
      );
      if (_attempts >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Too many incorrect attempts. The app will close now.",
            ),
          ),
        );
        Future.delayed(Duration(seconds: 2), () {
          SystemNavigator.pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Password Reset",
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
        iconTheme: IconThemeData(color: Colors.white),
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
                "Enter the management code to proceed with your password reset procedure.",
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
              // Using the custom text field for consistency.
              CustomTextField(
                controller: _managementCodeController,
                hintText: "Management Code",
                obscureText: true,
                hintColor:
                    themeProvider.isDarkMode
                        ? (Colors.grey[400] ?? Colors.grey)
                        : (Colors.grey[700] ?? Colors.grey),
                // Change textColor for dark mode to black for better contrast
                textColor:
                    themeProvider.isDarkMode
                        ? Colors.black
                        : const Color(0xFF212121),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyManagementCode,
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
                child: const Text(
                  "Proceed",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // <-- Bold text
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
