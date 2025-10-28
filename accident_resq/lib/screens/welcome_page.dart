import 'package:flutter/material.dart';
import '../constants.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome';
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // 1. Top Image Placeholder (The white/pale blue background in the image)
          Positioned.fill(
            top: 0,
            // Occupies about 60% of height
            bottom: mediaQuery.size.height * 0.4,
            child: Container(
              alignment: Alignment.center,
              // Simulate the curved background top section
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(mediaQuery.size.height * 0.1),
                  bottomRight: Radius.circular(mediaQuery.size.height * 0.1),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 60.0),
                child: Text(
                  'Your App Visuals Here',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // 2. Bottom Content (The buttons and links)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(
                top: 40,
                left: 32,
                right: 32,
                bottom: 32 + mediaQuery.padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Login Button (Dark background)
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 16),

                  // Register Button (Outlined/White background)
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/signup'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 24),

                  // Continue as a guest link
                  TextButton(
                    onPressed: () {
                      // Action for guest login
                    },
                    child: const Text(
                      'Continue as a guest',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
