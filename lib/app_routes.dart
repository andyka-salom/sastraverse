import 'package:flutter/material.dart';
import 'package:sastraverse/page/login.dart';
import 'package:sastraverse/page/signup.dart';
import 'package:sastraverse/page/onboarding.dart';
import 'package:sastraverse/page/get_started.dart';
import 'package:sastraverse/main.dart';
import 'package:sastraverse/page/search.dart';
import 'package:sastraverse/page/profile.dart';
import 'package:sastraverse/page/mainlayout.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcomeScreen = '/welcomeScreen';
  static const String initialRoute = search;
  static const String search = '/search';
  static const String profile = '/profile';
  static const String mainLayout = '/mainLayout';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    signup: (context) => const SignUpPage(),
    splash: (context) => const SplashPage(),
    welcomeScreen: (context) => const WelcomeScreen(),
    onboarding: (context) => const OnboardingPage(),
    search: (context) => const SearchPage(),
    profile: (context) => const ProfilePage(),
    mainLayout: (context) => const MainLayout()
  };
}