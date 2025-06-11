import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // Optional: Add an app bar
      ),
      body: const Center(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(
                'assets/iicnos/default_profile_icon.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
