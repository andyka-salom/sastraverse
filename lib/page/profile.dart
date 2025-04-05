import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appearance/appearance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  int age = 0;
  String profileImageUrl = "";
  String? userId;

  bool _isLoading = false;
  bool _isFetchingData = true;

  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String defaultAvatarAssetPath = 'assets/images/foto.jpg';


  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
     setState(() => _isFetchingData = true);
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      userId = currentUser.uid;
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
        if (mounted && userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            name = data['name'] ?? '';
            email = currentUser.email ?? data['email'] ?? '';
            age = data['age'] ?? 0;
            profileImageUrl = data['profileImageUrl'] ?? '';
            _initializeControllers();
          });
        } else if (mounted) { print("User document not found for UID: $userId"); /* Handle */ }
      } catch (e) { if(mounted) { print("Error fetching user data: $e"); /* Handle */ }
      } finally { if (mounted) { setState(() => _isFetchingData = false); } }
    } else { print("No user logged in!"); if (mounted) { setState(() => _isFetchingData = false); /* Handle */ } }
  }

  void _initializeControllers() {
    _nameController.text = name;
    _emailController.text = email;
    _ageController.text = age > 0 ? age.toString() : '';
  }

  @override
  void dispose() {
    _nameController.dispose(); _emailController.dispose(); _ageController.dispose();
    super.dispose();
  }


  Future<void> _saveProfile() async {
     if (_isLoading || userId == null) return;
    setState(() => _isLoading = true);
    try {
      String newName = _nameController.text.trim();
      int newAge = int.tryParse(_ageController.text.trim()) ?? age;
      await _firestore.collection('users').doc(userId).update({'name': newName, 'age': newAge});
      if (mounted) { setState(() { name = newName; age = newAge; });}
    } catch (e) { if (mounted) { print("Error saving profile: $e");}
    } finally { if (mounted) { setState(() => _isLoading = false); } }
  }

  Future<void> _changeProfilePicture() async {
     print("Change profile picture tapped"); if(mounted) {}
  }

  Future<void> _logout() async { 
     print("Logout tapped");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance(); await prefs.remove('user_uid');
      await _auth.signOut();
      if (mounted) { Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false); }
    } catch (e) { if(mounted) { print("Error logging out: $e");} }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ImageProvider avatarImageProvider;
    if (profileImageUrl.isNotEmpty) {
        avatarImageProvider = NetworkImage(profileImageUrl);
    } else {
       avatarImageProvider = const AssetImage(defaultAvatarAssetPath);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: theme.appBarTheme.elevation ?? 0.5,
        foregroundColor: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.titleTextStyle?.color ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600
          )
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isFetchingData
            ? const Center(child: CircularProgressIndicator.adaptive())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            backgroundImage: avatarImageProvider,
                            onBackgroundImageError: (exception, stackTrace) {
                              print("Error loading avatar image: $exception");
                            },
                          ),
                          // Tombol Edit Foto
                          Material(
                             color: theme.colorScheme.primary,
                             shape: const CircleBorder(),
                             clipBehavior: Clip.antiAlias,
                             elevation: 2,
                            child: InkWell(
                              onTap: _changeProfilePicture,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0), // Padding lebih kecil
                                child: Icon(
                                  Platform.isIOS ? CupertinoIcons.pencil : Icons.edit, // Ikon edit
                                  size: 18, // Ukuran ikon lebih kecil
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                       if (name.isNotEmpty) 
                         Padding(
                           padding: const EdgeInsets.only(bottom: 24.0),
                           child: Text(
                             name,
                             style: GoogleFonts.poppins(
                               fontSize: 22,
                               fontWeight: FontWeight.w600,
                               color: theme.textTheme.titleLarge?.color
                             ),
                             textAlign: TextAlign.center,
                           ),
                         ),
                       if (name.isEmpty && !_isFetchingData)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              'Update Your Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: theme.hintColor
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),


                      // --- Form Edit ---
                       _buildSectionTitle(context, 'Edit Information'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        labelText: 'Username',
                        controller: _nameController,
                        icon: Platform.isIOS ? CupertinoIcons.person : Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        labelText: 'Email',
                        controller: _emailController,
                        icon: Platform.isIOS ? CupertinoIcons.mail : Icons.email_outlined,
                        readOnly: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        labelText: 'Age',
                        controller: _ageController,
                        icon: Platform.isIOS ? CupertinoIcons.gift : Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      // --- Tombol Save ---
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const SizedBox( height: 24, width: 24, child: CircularProgressIndicator.adaptive( strokeWidth: 3, backgroundColor: Colors.white54,))
                            : const Text('Save Changes'),
                      ),
                      const SizedBox(height: 30),

                      // --- Bagian Settings ---
                      const Divider(), // Pemisah
                      const SizedBox(height: 16),
                      _buildSectionTitle(context, 'Settings'),
                      const SizedBox(height: 8),
                      _buildSettingsSection(context), // Dark Mode Toggle
                      const SizedBox(height: 24),

                       // --- Tombol Logout ---
                      const Divider(), // Pemisah
                      const SizedBox(height: 16),
                      TextButton.icon(
                         style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Tambah border radius
                        ),
                        icon: Icon(Platform.isIOS ? CupertinoIcons.square_arrow_right : Icons.logout, size: 20),
                        label: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)), // Teks lebih besar
                        onPressed: _logout,
                       ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Helper untuk Judul Section
  Widget _buildSectionTitle(BuildContext context, String title) {
     final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.textTheme.titleMedium?.color,
        ),
      ),
    );
  }


  // Helper Widget untuk TextField (Disederhanakan)
  Widget _buildTextField({
    required BuildContext context,
    required String labelText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
     final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: theme.hintColor),
        prefixIcon: Icon(icon, color: theme.hintColor, size: 20),
        filled: true,
        // Warna fill dari tema input decoration atau fallback
        fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Padding lebih rapat
        border: OutlineInputBorder( // Gunakan border standar tema atau kustom
          borderRadius: BorderRadius.circular(12.0), // Radius konsisten
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12.0),
           borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12.0),
           borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder( // Style saat readOnly/disabled
          borderRadius: BorderRadius.circular(12.0),
           borderSide: BorderSide(color: theme.disabledColor.withOpacity(0.3), width: 1),
        ),
      ),
    );
   }


  // Helper Widget untuk Bagian Settings (Lebih Rapi)
  Widget _buildSettingsSection(BuildContext context) {
      final theme = Theme.of(context);
    final appearance = Appearance.of(context);
    final bool isCurrentlyDark = appearance?.mode == ThemeMode.dark;

    // Bungkus dengan Card untuk elevasi/batas
    return Card(
      elevation: 0.5, // Elevasi halus
      margin: EdgeInsets.zero, // Hapus margin default Card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Radius konsisten
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5), // Warna latar card
      child: ListTile(
         // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Padding ListTile
        leading: Icon(
          Platform.isIOS ? CupertinoIcons.moon_stars : Icons.brightness_6_outlined, // Outline ikon
          color: theme.textTheme.bodyLarge?.color,
        ),
        title: Text(
          'Dark Mode',
          style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w500),
        ),
        trailing: Switch.adaptive(
           value: isCurrentlyDark,
          onChanged: (value) {
            appearance?.setMode( value ? ThemeMode.dark : ThemeMode.light, );
            print("Dark Mode set via Appearance: $value");
          },
          activeColor: theme.colorScheme.primary,
         ),
       ),
    );
   }
}