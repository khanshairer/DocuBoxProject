import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

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
            // Ensure the widget is still mounted before using context
            // If the widget is not mounted, it means it has been removed from the widget tree, and you should not use context to navigate or show dialogs.
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return; // ✅ safe context usage
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
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
