import 'package:flutter/material.dart';

class AccountNavigation extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onPressed;

  const AccountNavigation({
    super.key,
    required this.text,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(color: Colors.grey),
        ),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            actionText,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}