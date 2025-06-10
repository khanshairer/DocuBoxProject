import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

TextStyle welcomePageText() {
  return GoogleFonts.poppins(
    fontSize: 24,
    letterSpacing: 4,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 10.0,
        color: Colors.amber,
        offset: const Offset(2.0, 2.0),
      ),
    ],
  );
}
