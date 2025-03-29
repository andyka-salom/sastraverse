import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WelcomeScreen(),
  ));
}

// === WELCOME SCREEN ===
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    // TODO: Handle back button press
                  },
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Ganti dengan path yang benar
                    height: 150,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  Text(
                    'SastraVerse',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Masuki SastraVerse dan temukan kisah yang menginspirasi.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 80.0, vertical: 16.0),
                  textStyle: GoogleFonts.poppins(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: const Text('Get Started'),
              ),
            ),
            const BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

// === HOME SCREEN ===
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SastraVerse',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  FilterButton(text: 'All', isSelected: true),
                  const SizedBox(width: 8),
                  FilterButton(text: 'Genre', icon: Icons.favorite_border),
                  const SizedBox(width: 8),
                  FilterButton(text: 'Saran', icon: Icons.lightbulb_outline),
                  const SizedBox(width: 8),
                  FilterButton(text: 'Rating', icon: Icons.star_border),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/images/book_cover.png', // Ganti path ini
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(), // Mendengarkan perubahan pada koleksi 'categories'
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No categories found.'));
                  }

                  return GridView.count(
                    crossAxisCount: 3,
                    padding: const EdgeInsets.all(16.0),
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return CategoryCard(
                        title: data['categories'],
                        description: data['description'],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

// === WIDGETS ===
class FilterButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isSelected;

  const FilterButton({
    Key? key,
    required this.text,
    this.icon,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8DEF8) : Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isSelected ? const Color(0xFF6750A4) : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 16, color: const Color(0xFF49454F)),
          if (icon != null) const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF49454F),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String description;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFE8DEF8), // Light lavender
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF49454F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


// === BOTTOM NAVIGATION BAR (Separated into its own file) ===
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(Icons.home, color: const Color(0xFF49454F)),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: const Color(0xFF6750A4),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const Icon(Icons.widgets, color: const Color(0xFF49454F)),
          const Icon(Icons.person_outline, color: const Color(0xFF49454F)),
        ],
      ),
    );
  }
}