import 'package:flutter/material.dart';
import 'page/login.dart';
import 'page/signup.dart';
import 'page/onboarding.dart';
import 'page/home.dart';
import '../main.dart';


class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String initialRoute = onboarding;

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginPage(),
    signup: (context) => SignUpPage(),
    splash: (context) => SplashPage(),
    home: (context) => WelcomeScreen(),
    onboarding: (context) => OnboardingPage(),
  };
}