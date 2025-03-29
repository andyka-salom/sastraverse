import 'package:flutter/material.dart';
import 'package:sastraverse/page/login.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/img1.png',
      'title': 'Temukan Dunia Sastra Baru',
      'description':
          'Jelajahi berbagai karya sastra dari beragam genre dan penulis berbakat.',
    },
    {
      'image': 'assets/images/img2.png',
      'title': 'Jelajahi Keajaiban Sastra',
      'description':
          'Akses karya favoritmu kapan saja, dimana saja, dan rasakan pengalaman tanpa batas.',
    },
    {
      'image': 'assets/images/img3.png',
      'title': 'Membuka Gerbang Imajinasi',
      'description':
          'Ekspresikan dirimu dengan menulis dan membagikan karya sastra kepada dunia',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8FF), // Soft background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Increased padding
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: _currentPage != 2
                    ? TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                        child: Text('Skip',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500)),
                      )
                    : null,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingItem(data: onboardingData[index]);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
              SizedBox(height: 24.0), // Added spacing
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _currentPage != 2
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPage > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[700],
                              elevation: 2,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 20,),
                          ),
                          ElevatedButton(
                            onPressed: _currentPage < onboardingData.length - 1
                                ? () {
                                    _pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[700],
                              elevation: 2,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Icon(Icons.arrow_forward_ios_rounded, size: 20,),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _navigateToLogin(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6750A4), // Primary color
                            foregroundColor: Colors.white,
                            elevation: 3,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text('Login / Sign Up',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < onboardingData.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF6750A4) : Colors.grey[400],
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class OnboardingItem extends StatelessWidget {
  final Map<String, String> data;

  const OnboardingItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: Image.asset(
                  data['image']!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 32.0),
          Text(
            data['title']!,
            style: GoogleFonts.poppins(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Text(
            data['description']!,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              color: Colors.grey[700],
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}