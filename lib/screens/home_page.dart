import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to DocuBox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              debugPrint("Sign out complete");

              // ✅ Don't navigate — let main.dart StreamBuilder handle it
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are logged in!'),
            const SizedBox(height: 10),
            if (user != null)
              Column(
                children: [
                  Text('Email: ${user.email ?? 'N/A'}'),
                  Text('UID: ${user.uid}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
