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
  // --- State Variables ---
  String name = "";
  String email = "";
  int age = 0;
  String profileImageUrl = "";
  String? userId;

  bool _isLoading = false; // For save button state
  bool _isFetchingData = true; // For initial data load

  // --- Controllers & Keys ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Constants ---
  static const String defaultAvatarAssetPath = 'assets/images/foto.jpg';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // --- Data Fetching ---
  Future<void> _fetchUserData() async {
    setState(() => _isFetchingData = true);
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      userId = currentUser.uid;
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (mounted && userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            name = data['name'] ?? '';
            // Prefer email from Auth, fallback to Firestore, then empty
            email = currentUser.email ?? data['email'] ?? '';
            age = data['age'] ?? 0;
            profileImageUrl = data['profileImageUrl'] ?? '';
            _initializeControllers(); // Initialize after fetching
          });
        } else if (mounted) {
          print("User document not found for UID: $userId");
          // Optionally set default values or show an error message
           email = currentUser.email ?? ''; // Still set email if available
           _initializeControllers();
        }
      } catch (e) {
        if (mounted) {
          print("Error fetching user data: $e");
          // Handle error (e.g., show Snackbar)
        }
      } finally {
        // Ensure loading state is turned off even if errors occur
        if (mounted) {
          setState(() => _isFetchingData = false);
        }
      }
    } else {
      print("No user logged in!");
       if (mounted) { setState(() => _isFetchingData = false); }
       // if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  void _initializeControllers() {
    _nameController.text = name;
    _emailController.text = email;
    _ageController.text = age > 0 ? age.toString() : '';
  }

  // --- Profile Actions ---
  Future<void> _saveProfile() async {

    if (_isLoading || userId == null) return;
    setState(() => _isLoading = true);

    try {
      String newName = _nameController.text.trim();
      int newAge = int.tryParse(_ageController.text.trim()) ?? age;
      Map<String, dynamic> dataToUpdate = {
        'name': newName,
        'age': newAge,
        // 'profileImageUrl': newImageUrl, // Update image URL if changed via _changeProfilePicture
      };

      await _firestore.collection('users').doc(userId).update(dataToUpdate);

      if (mounted) {
        setState(() {
          name = newName;
          age = newAge;
          // Show success feedback (e.g., Snackbar)
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error saving profile: $e");
        // Show error feedback
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error saving profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Ensure loading state is turned off
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    print("Change profile picture tapped - Implementation needed");
    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Image change feature not yet implemented.')),
        );
    }
  }

  Future<void> _logout() async {
    print("Logout tapped");
    final bool confirmLogout = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: const Text('Logout'),
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmLogout || !mounted) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_uid');
      await _auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        print("Error logging out: $e");
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error logging out: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color onPrimaryColor = theme.colorScheme.onPrimary;
    final Color primaryColor = theme.colorScheme.primary;
    final Color scaffoldColor = theme.scaffoldBackgroundColor;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceVarColor = theme.colorScheme.surfaceVariant;

    final ImageProvider avatarImageProvider = (profileImageUrl.isNotEmpty)
        ? NetworkImage(profileImageUrl)
        : const AssetImage(defaultAvatarAssetPath);


    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? surfaceVarColor,
        elevation: theme.appBarTheme.elevation ?? 0.5,
        foregroundColor: theme.appBarTheme.foregroundColor ?? onSurfaceColor,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
              color: theme.appBarTheme.titleTextStyle?.color ?? onSurfaceColor,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isFetchingData
            ? const Center(child: CupertinoActivityIndicator(radius: 15))
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
                            backgroundColor: surfaceVarColor,
                            foregroundImage: avatarImageProvider,
                            backgroundImage: const AssetImage(defaultAvatarAssetPath),
                            onForegroundImageError: (exception, stackTrace) {
                               print("Error loading network avatar, using default. Error: $exception");
                            },
                          ),
                          Material(
                            color: primaryColor,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            elevation: 2,
                            child: InkWell(
                              onTap: _changeProfilePicture,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  CupertinoIcons.pencil,
                                  size: 18,
                                  color: onPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Display Name ---
                       Padding(
                         padding: const EdgeInsets.only(bottom: 24.0),
                         child: Text(
                           name.isNotEmpty ? name : 'Update Your Profile',
                           style: GoogleFonts.poppins(
                             fontSize: name.isNotEmpty ? 22 : 18,
                             fontWeight: name.isNotEmpty ? FontWeight.w600 : FontWeight.w500,
                             color: name.isNotEmpty
                                ? theme.textTheme.titleLarge?.color
                                : theme.hintColor,
                           ),
                           textAlign: TextAlign.center,
                         ),
                       ),

                      // --- Form Fields Section ---
                      _buildSectionTitle(context, 'Edit Information'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        labelText: 'Username',
                        controller: _nameController,
                        icon: CupertinoIcons.person, 
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        labelText: 'Email',
                        controller: _emailController,
                        icon: CupertinoIcons.mail,
                        readOnly: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        labelText: 'Age',
                        controller: _ageController,
                        icon: CupertinoIcons.gift,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      // --- Save Button ---
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: onPrimaryColor,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const CupertinoActivityIndicator(color: Colors.white)
                            : const Text('Save Changes'),
                      ),
                      const SizedBox(height: 30),

                      // --- Settings Section ---
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context, 'Settings'),
                      const SizedBox(height: 8),
                      // Use helper for settings row
                      _buildSettingsSection(context),
                      const SizedBox(height: 24),

                      // --- Logout Button ---
                      const Divider(), // Material Divider
                      const SizedBox(height: 16),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(CupertinoIcons.square_arrow_right, size: 20),
                        label: Text('Logout',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Helper for Section Title Text
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
        ),
      ),
    );
  }

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
    final bool isEffectivelyEnabled = !readOnly;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      enabled: isEffectivelyEnabled,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: isEffectivelyEnabled
            ? (theme.textTheme.bodyLarge?.color)
            : theme.disabledColor,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(
          color: isEffectivelyEnabled ? theme.hintColor : theme.disabledColor.withOpacity(0.7)
        ),
        prefixIcon: Icon(icon, color: isEffectivelyEnabled ? theme.hintColor : theme.disabledColor.withOpacity(0.7), size: 20),
        filled: true,
        fillColor: readOnly
             ? theme.disabledColor.withOpacity(0.05)
             : (theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.4)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
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
        // Style for readOnly state
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.disabledColor.withOpacity(0.2), width: 1),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final theme = Theme.of(context);
    final appearance = Appearance.of(context);
    final bool isCurrentlyDark = appearance?.mode == ThemeMode.dark;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5), width: 1)
      ),
      color: theme.cardColor,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(
          CupertinoIcons.moon_stars,
          color: theme.textTheme.bodyLarge?.color,
        ),
        title: Text(
          'Dark Mode',
          style: GoogleFonts.poppins(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500),
        ),
        trailing: Switch.adaptive(
          value: isCurrentlyDark,
          onChanged: (value) {
            appearance?.setMode(
              value ? ThemeMode.dark : ThemeMode.light,
            );
            print("Dark Mode set via Appearance: $value");
          },
          activeColor: theme.colorScheme.primary,
        ),
        onTap: () {
            appearance?.setMode(
              !isCurrentlyDark ? ThemeMode.dark : ThemeMode.light,
            );
        },
      ),
    );
  }
}