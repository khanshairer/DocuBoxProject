import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // Optional: Add an app bar
      ),
      body: const Center(
        child: Text(
          'Welcome to your Profile!',
        ), // Your profile content goes here
      ),
    );
  }
}
