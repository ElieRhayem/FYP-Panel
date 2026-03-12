import 'package:flutter/material.dart';
import 'package:mobile_application/views/auth/loginScreen.dart';
import 'package:mobile_application/views/auth/signupScreen.dart';
import 'package:mobile_application/views/auth/emailToResetPass.dart';
import 'package:mobile_application/views/auth/emailVerification.dart';
import 'package:mobile_application/views/auth/managementCode_screen.dart';
import 'package:mobile_application/views/common/loading_screen.dart';
import 'package:mobile_application/views/common/uiScreen.dart';
import 'package:mobile_application/views/common/logs_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/loading/': (context) => const LoadingScreen(),
  '/logIn/': (context) => LoginScreen(),
  '/signUp/': (context) => SignUpScreen(),
  '/emailVerification/': (context) => EmailVerificationScreen(),
  '/management/': (context) => ManagementCodeScreen(),
  '/resetPass/': (context) => PasswordResetEmailScreen(),
  '/mainUi/': (context) => const MachineListScreen(),
  '/logs/': (context) => const LogsScreen(),
};