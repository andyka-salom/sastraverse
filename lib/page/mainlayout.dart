import 'package:flutter/material.dart';
import '../page/home.dart'; // Import HomeScreen
import '../page/search.dart';
import '../page/profile.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Define a list of widgets for each tab
  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Home
    const SearchPage(),  // Search
    const ProfilePage(),  //Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, theme),
            _buildNavItem(1, Icons.widgets, theme),
            _buildNavItem(2, Icons.person_outline, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, ThemeData theme) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.textTheme.bodyMedium!.color),
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6750A4) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}