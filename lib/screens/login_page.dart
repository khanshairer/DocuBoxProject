import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart'; // Ensure go_router is imported

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';
  bool _isLoading = false; // NEW: State variable for loading indicator

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Handles email/password login and navigates to the home page on success.
  Future<void> _loginWithEmail() async {
    if (!mounted) return; // Ensure widget is mounted before setting state
    setState(() {
      error = '';
      _isLoading = true; // Show loading indicator
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return; // Ensure widget is mounted before navigating
      context.go('/'); // Use go_router for navigation
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => error = e.message ?? 'Login failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Hide loading indicator
      }
    }
  }

  /// Handles Google Sign-In and navigates to the home page on success.
  Future<void> _loginWithGoogle() async {
    if (!mounted) return; // Ensure widget is mounted before setting state
    setState(() {
      error = '';
      _isLoading = true; // Show loading indicator
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the Google sign-in process
        if (mounted) {
          setState(() => _isLoading = false); // Hide loading indicator
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return; // Ensure widget is mounted before navigating
      context.go('/'); // Use go_router for navigation
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => error = e.message ?? 'Google sign-in failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Hide loading indicator
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body:
          _isLoading // Show loading indicator if true, otherwise show the form
              ? const Center(child: CircularProgressIndicator())
              : Padding(
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
                        onPressed:
                            _isLoading
                                ? null
                                : _loginWithEmail, // Disable button when loading
                        child: const Text("Login"),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Google Sign-In Button
                    GestureDetector(
                      onTap:
                          _isLoading
                              ? null
                              : _loginWithGoogle, // Disable button when loading
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
                            // Ensure 'assets/icons/google_logo.png' exists in your pubspec.yaml
                            Image.asset(
                              'assets/icons/google_logo.png',
                              height: 24,
                            ),
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
                        child: Text(
                          error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () => context.go(
                                '/signup',
                              ), // Use go_router for navigation and disable when loading
                      child: const Text("Don't have an account? Sign Up"),
                    ),
                  ],
                ),
              ),
    );
  }
}
