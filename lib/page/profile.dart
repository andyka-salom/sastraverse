import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Replace with data fetched from Firebase
  int age = 20;
  String email = "";
  String name = "";
  String profileImageUrl = "";
  String userId = "";

  // Controller for managing data in input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _profileImageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text field controllers with the existing data
    _nameController.text = name;
    _emailController.text = email;
    _ageController.text = age.toString();
    _profileImageUrlController.text = profileImageUrl;
  }
  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Make body extend behind AppBar
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyMedium!.color), // Themed back button
        title: Text('Profile', style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium!.color, fontWeight: FontWeight.w500)),
        centerTitle: true, // Center the title
      ),
      body: Stack(
        children: [
          // Blurred Background
          Positioned.fill(
            child: Image.network(
              profileImageUrl.isNotEmpty ? profileImageUrl : 'https://images.unsplash.com/photo-1604136542456-a92a69e58515?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGJsYWNrfGVufDB8fDB8fHww', // Replace with a URL or asset image
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback when image URL is not valid
                return Container(color: Theme.of(context).scaffoldBackgroundColor);
              },
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),
          // Profile Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Image
                  Center(
                    child: Hero(
                      tag: 'profileImage',
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Add functionality to view full image
                        },
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Name
                  _buildTextField(
                    labelText: 'Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // Email
                  _buildTextField(
                    labelText: 'Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Age
                  _buildTextField(
                    labelText: 'Age',
                    controller: _ageController,
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Profile Image URL
                  _buildTextField(
                    labelText: 'Profile Image URL',
                    controller: _profileImageUrlController,
                    icon: Icons.image_outlined,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      // TODO: Implement data saving
                    },
                    child: Text('Save', style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium!.color),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}