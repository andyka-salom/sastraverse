import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/accountnav.dart';
import '../widgets/authbutton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_routes.dart';
import 'package:appearance/appearance.dart'; // Import Appearance
import '../widgets/text_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Fungsi _login() Tetap Sama ---
  Future<void> _login() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        final String userId = user.uid;
        final DocumentReference userDocRef = _firestore.collection('users').doc(userId);
        final DocumentSnapshot userDocSnapshot = await userDocRef.get();
        if (!userDocSnapshot.exists) {
          print('User document for $userId does not exist. Creating...');
          try {
            await userDocRef.set({
              'age': 20, 'email': user.email ?? '', 'name': '', 'profileImageUrl': '', 'userId': userId, 'createdAt': FieldValue.serverTimestamp(),
            });
             print('User document created successfully.');
          } catch (e) { print('Error creating user document: $e'); /* Handle */ setState(() => _isLoading = false); return; }
        } else { print('User document for $userId already exists.'); }
        SharedPreferences prefs = await SharedPreferences.getInstance(); await prefs.setString('user_uid', userId);
        print('User UID saved to SharedPreferences.');
        if (mounted) { setState(() => _isLoading = false); Navigator.pushReplacementNamed(context, AppRoutes.welcomeScreen); }
      } else { if (mounted){ /* Handle user null */ } }
    } on FirebaseAuthException catch (e) { print('FirebaseAuthException: ${e.code} - ${e.message}'); String msg = '...'; /* Set error message based on e.code */ if (mounted){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))); }
    } catch (e) { print('General Login Error: $e'); if (mounted){ /* Handle general error */ }
    } finally { if (mounted && _isLoading) { setState(() => _isLoading = false); } }
  }
  // --- Akhir Fungsi _login() ---

  @override
  Widget build(BuildContext context) {
    final appearance = Appearance.of(context);
    final isDarkMode = appearance?.mode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 1), //  placeholder
                    Switch( // Theme Switch
                      value: isDarkMode,
                      onChanged: (value) {
                        appearance?.setMode(value ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ],
                ),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Login Your Account',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 40),

                // Email TextField
                ThemedTextField(
                  controller: _emailController,
                  hintText: 'Enter Your Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password TextField
                ThemedTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Forgot Password?
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password functionality
                    },
                    child: const Text(
                      'Forget Password ?',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                AuthButton(text: 'Login', onPressed: _login),
                const SizedBox(height: 20),

                // Create New Account?
                 AccountNavigation(
                  text: 'Create New Account? ',
                  actionText: 'Sign up',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  textColor: Theme.of(context).textTheme.bodyMedium!.color!,// Themed Text
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}