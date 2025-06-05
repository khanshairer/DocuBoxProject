import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView(
              children: [
                Container(
                  color: Colors.blue,
                  child: const Center(child: Text('Welcome to the App!')),
                ),
                Container(
                  color: Colors.green,
                  child: const Center(child: Text('Enjoy your stay!')),
                ),
                Container(
                  color: Colors.red,
                  child: const Center(child: Text('Have fun!')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
