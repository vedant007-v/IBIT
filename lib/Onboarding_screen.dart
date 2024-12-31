import 'package:flutter/material.dart';
import 'package:iBIT/loginpage.dart';
import 'package:iBIT/signuppage.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the PageController to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[700],
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              OnboardingSlide(
                imageAsset: 'assets/obbg1.png',
                title: 'Welcome to iBIT App',
                description: 'Effortlessly analyze sediment samples with precision using this app, which extracts shape and structure data swiftly for geologists and researchers alike.',
              ),
              OnboardingSlide(
                imageAsset: 'assets/obbgs3.png',
                title: 'Feature Extraction',
                description: 'Dive into lab studies exploring soil particles, unraveling their composition and properties for comprehensive analysis.',
              ),
              OnboardingSlide(
                imageAsset: 'assets/obbg3.png',
                title: 'Get Started',
                description: 'Discover the ultimate destination for all sediment extraction needs.',
                showButtons: true,
              ),
            ],
          ),
          Positioned(
            bottom: 30.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(3, (index) => _buildDot(index)),
                ),
                _currentPage != 2
                    ? TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      width: _currentPage == index ? 12.0 : 8.0,
      height: _currentPage == index ? 12.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;
  final bool showButtons;

  const OnboardingSlide({
    required this.imageAsset,
    required this.title,
    required this.description,
    this.showButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageAsset),
          SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blue[100],
              fontFamily: 'Schyler',
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              description,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20),
          if (showButtons) _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.purple[400],
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignUpPage()),
            );
          },
          child: Text('Sign Up'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.purple[400],
            backgroundColor: Colors.white,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: Text('Log In'),
        ),
      ],
    );
  }
}
