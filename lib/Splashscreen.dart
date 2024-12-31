import 'package:flutter/material.dart';
import 'package:iBIT/Onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use Future.delayed to navigate after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to OnboardingScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey, // Set your desired background color
      body: Center(
        child: Image.asset(
          'assets/sslogo.png', // Adjust the path according to your logo file
          width: 200, // Adjust the width according to your logo size
          height: 200, // Adjust the height according to your logo size
        ),
      ),
    );
  }
}
