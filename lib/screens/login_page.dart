import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import 'signup_page.dart';
import "home_page.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';
  bool _isLoading = false;

  // login successful, navigate to home page
  // considering using a mounted option to check if the widget is still in the tree
  //If the user navigates away or the widget is disposed during the await, using context can crash the app or cause unexpected behavior.

  Future<void> _loginWithEmail() async {
    setState(() {
      error = '';
      _isLoading = true;
    });

    try {
      // Attempt login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      // Navigate to home if successful
      context.go('/');
    } on FirebaseAuthException catch (e) {
      // Show error message
      setState(() => error = e.message ?? 'Login failed');
    } catch (e) {
      // Catch-all for other errors
      setState(() => error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  //First Check Mounted state before using context
  //If the widget is not mounted, it means it has been removed from the widget tree, and you should not use context to navigate or show dialogs.

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return; // ✅ Make sure the widget is still active
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => error = e.message ?? 'Google sign-in failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            // Email/Password Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loginWithEmail,
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 10),

            // Google Sign-In Button
            GestureDetector(
              onTap: _loginWithGoogle,
              child: Container(
                width: double.infinity, // Match width to login button
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/google_logo.png', height: 24),
                    const SizedBox(width: 10),
                    const Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),
            TextButton(
              child: const Text("Don't have an account? Sign Up"),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
