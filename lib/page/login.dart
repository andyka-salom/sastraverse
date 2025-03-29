import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/accountnav.dart';
import '../widgets/customtextfield.dart';
import '../widgets/authbutton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_routes.dart';

class LoginPage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const LoginPage({Key? key});

  @override
  // ignore: library_private_types_in_public_api
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
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Could not retrieve user information.')),
        );
      }

    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                  ),
                ),

                const SizedBox(height: 30),
                // Login Title
                const Text(
                  'Login Your Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A3A55),
                  ),
                ),
                const SizedBox(height: 40),

                // Email TextField (Using Component)
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter Your Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password TextField (Using Component)
                CustomTextField(
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

                // Login Button (Using Component)
                AuthButton(text: 'Login', onPressed: _login),
                const SizedBox(height: 20),

                // Create New Account? (Using Component)
                AccountNavigation(
                  text: 'Create New Account? ',
                  actionText: 'Sign up',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
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
