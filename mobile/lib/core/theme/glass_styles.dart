import 'package:flutter/material.dart';

class GlassStyles {
  /// Box decoration for the glass card effect
  static BoxDecoration get glassCardDecoration {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.03),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Linear gradient mimicking the pseudo-element gradient border
  static LinearGradient get borderGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.15),
        const Color(0xFF4F8EF7).withOpacity(0.05),
      ],
    );
  }
  
  static BoxDecoration get glassNavBarDecoration {
    return BoxDecoration(
      color: const Color(0xFF051424).withOpacity(0.8),
      border: Border(
        top: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
    );
  }
}
