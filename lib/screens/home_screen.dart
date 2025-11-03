import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Logout button in the AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Sign out from Firebase
              FirebaseAuth.instance.signOut();
              // The AuthWrapper will automatically handle navigation
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          'You are logged in!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}