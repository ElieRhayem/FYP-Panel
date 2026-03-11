import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_application/services/firebase_auth_service.dart';

class LoginResult {
  final bool isSuccess;
  final bool userEmailVerified;
  final String errorMessage;

  LoginResult({
    required this.isSuccess,
    this.userEmailVerified = false,
    this.errorMessage = '',
  });
}

class SignUpResult {
  final bool isSuccess;
  final String errorMessage;

  SignUpResult({required this.isSuccess, this.errorMessage = ''});
}

class PasswordResetResult {
  final bool isSuccess;
  final String errorMessage;

  PasswordResetResult({required this.isSuccess, this.errorMessage = ''});
}

class EmailVerificationResult {
  final bool isSuccess;
  final String errorMessage;

  EmailVerificationResult({required this.isSuccess, this.errorMessage = ''});
}

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService;

  AuthViewModel(this._authService);

  Future<LoginResult> login(String email, String password) async {
    try {
      // Delegating the Firebase call to the service
      UserCredential userCredential = await _authService
          .signInWithEmailAndPassword(email, password);
      User? user = userCredential.user;
      return LoginResult(
        isSuccess: true,
        userEmailVerified: user != null && user.emailVerified,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to sign in.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Please try again.";
      }
      return LoginResult(isSuccess: false, errorMessage: errorMessage);
    } catch (e) {
      return LoginResult(
        isSuccess: false,
        errorMessage: "Failed to sign in: ${e.toString()}",
      );
    }
  }

  Future<SignUpResult> signUp(
      String email,
      String password,
      String managementPassword,
      ) async {
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(email, password);
      final user = userCredential.user;

      if (user != null) {
        // Add manager info to Firestore
        await FirebaseFirestore.instance
            .collection('Managers')
            .doc(user.uid)
            .set({
          'email': email,
          'createdAt': Timestamp.now(),
          // Add more fields if needed
        });
      }

      return SignUpResult(isSuccess: true);
    } on FirebaseAuthException catch (e) {
      return SignUpResult(
        isSuccess: false,
        errorMessage: e.message ?? "Failed to create account.",
      );
    } catch (e) {
      return SignUpResult(isSuccess: false, errorMessage: e.toString());
    }
  }

  Future<PasswordResetResult> sendPasswordResetEmail(String email) async {
    try {
      // Step 1: Check if the email exists in Managers collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Managers')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // No manager found with this email
        return PasswordResetResult(
          isSuccess: false,
          errorMessage: "This email is not associated with any manager account.",
        );
      }

      // Step 2: Send reset email
      await _authService.sendPasswordResetEmail(email);
      return PasswordResetResult(isSuccess: true);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "";
      if (e.code == 'invalid-email') {
        errorMessage = "Enter a valid email address.";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "Network error. Please try again.";
      } else {
        errorMessage = e.message ?? "An error occurred.";
      }
      return PasswordResetResult(isSuccess: false, errorMessage: errorMessage);
    } catch (e) {
      return PasswordResetResult(
        isSuccess: false,
        errorMessage: "Unexpected error: $e",
      );
    }
  }


  Future<void> signOut() async {
    await _authService.signOut();
  }
}

extension EmailVerificationMethods on AuthViewModel {
  Future<EmailVerificationResult> sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      return EmailVerificationResult(isSuccess: true);
    } catch (e) {
      return EmailVerificationResult(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> checkEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
