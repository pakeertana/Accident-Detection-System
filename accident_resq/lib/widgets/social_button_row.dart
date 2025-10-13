import 'package:flutter/material.dart';
import '../constants.dart';

class SocialButtonRow extends StatelessWidget {
  const SocialButtonRow({super.key});
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialIcon(
          icon: Icon(Icons.facebook, color: Colors.blue, size: 28),
        ),
        SizedBox(width: 20),
        SocialIcon(
          icon: Icon(Icons.alternate_email, color: Colors.red, size: 28), 
        ),
        SizedBox(width: 20),
        SocialIcon(
          icon: Icon(Icons.apple, color: Colors.black, size: 28),
        ),
      ],
    );
  }
}

class SocialIcon extends StatelessWidget {
  final Icon icon;
  const SocialIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kInputFill,
        borderRadius: BorderRadius.circular(kBorderRadius / 2),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: icon,
    );
  }
}