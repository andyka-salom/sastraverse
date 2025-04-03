// In your accountnav.dart file:

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountNavigation extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onPressed;
  final Color textColor; // Add textColor parameter

  const AccountNavigation({
    Key? key,
    required this.text,
    required this.actionText,
    required this.onPressed,
    required this.textColor,  // Set as Required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(color: textColor), //Custom argument to return style
        ),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            actionText,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: textColor, // Custom argument to return style
            ),
          ),
        ),
      ],
    );
  }
}