import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery/pages/authentication_page/login.dart';
import 'package:food_delivery/service/database.dart';
import 'package:food_delivery/service/shared_pref.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isWaitingForVerification = false;
  final int verificationTimeoutSeconds = 120;  // 2-minute timeout

  // Function to change email
  Future<void> changeEmail(BuildContext context, String newEmail, String password) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);

        // Initiate email change and send verification email
        await user.verifyBeforeUpdateEmail(newEmail);

        // Set waiting state
        setState(() {
          _isWaitingForVerification = true;
        });

        // Show a dialog to inform the user to verify their email
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Verify Email"),
              content: const Text("A verification email has been sent to your new email address. Please verify it to complete the update within 2 minutes."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _emailController.clear();
                    _passwordController.clear();

                    // Start checking for email verification
                    _checkVerificationStatus(newEmail);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } catch (error) {
        _handleAuthError(context, error);
      }
    }
  }

  void _handleAuthError(BuildContext context, dynamic error) {
    String errorMessage = "An error occurred";
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'email-already-in-use':
          errorMessage = "This email is already in use.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is invalid.";
          break;
        default:
          errorMessage = error.message ?? errorMessage;
          break;
      }
    }

    // Show error message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Periodically check if email has been verified
  Future<void> _checkVerificationStatus(String newEmail) async {
    int checkIntervalSeconds = 5;  // Check every 5 seconds
    int elapsedSeconds = 0;

    setState(() {
      _isWaitingForVerification = true;
    });

    await Future.delayed(const Duration(seconds: 5));

    while (elapsedSeconds < verificationTimeoutSeconds) {
      await Future.delayed(Duration(seconds: checkIntervalSeconds));
      elapsedSeconds += checkIntervalSeconds;

      // Reload user to get latest verification status
      await FirebaseAuth.instance.currentUser?.reload();
      User? user = FirebaseAuth.instance.currentUser;  // Refresh reference to user

      if (user != null && user.emailVerified) {
        // Email is verified, update Firestore and SharedPreferences
        await DatabaseMethods().updateUserEmail(user.uid, newEmail);
        await SharedPreferenceHelper().saveUserEmail(newEmail);

        // Show success message and prompt for re-login
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("Please verify your email and log in again with new email."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
                    _emailController.clear();
                    _passwordController.clear();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        // Exit the function since verification was successful
        setState(() {
          _isWaitingForVerification = false;
        });
        return;
      }
    }

    // If we exit the loop, it means the timeout was reached without verification
    setState(() {
      _isWaitingForVerification = false;
    });

    // Show timeout dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Verification Timeout"),
          content: const Text("Email verification was not completed in time. Please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Form submission method
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newEmail = _emailController.text.trim();
      final password = _passwordController.text.trim();
      changeEmail(context, newEmail, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Email"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'New Email',
                  hintText: 'Enter your new email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter your current password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Update Email'),
              ),
              if (_isWaitingForVerification)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      Text("Awaiting email verification..."),
                      SizedBox(height: 8),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
