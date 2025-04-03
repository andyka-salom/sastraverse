import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _obscurePassword = true;

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_uid', user.uid);
        Navigator.pushReplacementNamed(context, AppRoutes.welcomeScreen);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Could not retrieve user information.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password.')),
      );
    }
  }

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