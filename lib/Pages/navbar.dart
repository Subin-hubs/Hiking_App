import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hiking/Pages/gear.dart';
import 'package:hiking/Pages/home.dart';
import 'package:hiking/Pages/maps.dart';
import 'package:hiking/Pages/profile.dart';
import 'package:hiking/Pages/trails.dart';

class Navbar extends StatefulWidget {
  final int currentIndex;
  final bool navigateOnInit;

  const Navbar(int i, bool bool, {
    super.key,
    this.currentIndex = 0,
    this.navigateOnInit = false,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late int _currentIndex;
  late final PageController _pageController;

  static const List<Widget> _pages = [
    Home(),
    Trails(),
    Maps(),
    Gear(),
    Profile(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.landscape_outlined),
      activeIcon: Icon(Icons.landscape),
      label: 'Trails',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map_outlined),
      activeIcon: Icon(Icons.map),
      label: 'Map',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.backpack_outlined),
      activeIcon: Icon(Icons.backpack),
      label: 'Gear',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blueAccent.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,
        items: _navItems,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}