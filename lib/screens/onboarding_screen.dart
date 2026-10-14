import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFEAF6F4),
              child: Center(
                // Replace with your illustration: Image.asset('assets/onboarding.png')
                child:  Center(
                  child: Image.asset(
                    'assets/Man.png',
                    width: 400,
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
              child: Column(
                children: [
                  const Text('Spend Smarter\nSave More',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kTeal,
                          fontSize: 32,
                          height: 1.15,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 36),
                  PrimaryButton(
                    label: 'Get Started',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/main'),
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
