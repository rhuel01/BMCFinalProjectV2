import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:ecommerce_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to Firebase auth changes in real-time
    return StreamBuilder<User?>(
      // This stream sends updates whenever auth state changes
      stream: FirebaseAuth.instance.authStateChanges(),

      // Builder runs every time the auth state changes
      builder: (context, snapshot) {

        // Show loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If snapshot has data, a user is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // If no data, no user is logged in
        return const LoginScreen();
      },
    );
  }
}