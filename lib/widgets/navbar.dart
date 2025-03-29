import 'package:flutter/material.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({Key? key}) : super(key: key);

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          _currentPageIndex = index;
          switch (index) {
            case 0: // Home
              Navigator.pushNamed(context, '/home');
              break;
            case 1: // Widgets
              Navigator.pushNamed(context, '/widgets');
              break;
            case 2: // Profile
              Navigator.pushNamed(context, '/profile');
              break;
          }
        });
      },
      currentIndex: _currentPageIndex,
      selectedItemColor: const Color(0xFF49454F),
      unselectedItemColor: const Color(0xFF49454F),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: const Color(0xFF49454F)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.widgets, color: const Color(0xFF49454F)),
          label: 'Widgets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, color: const Color(0xFF49454F)),
          label: 'Profile',
        ),
      ],
    );
  }
}