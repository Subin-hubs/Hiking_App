import 'dart:async';

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();

  final List<String> images = [
    'assets/Home_Screen_photo/1.jpeg',
    'assets/Home_Screen_photo/2.jpeg',
    'assets/Home_Screen_photo/3.jpeg',
    'assets/Home_Screen_photo/4.jpeg',
    'assets/Home_Screen_photo/5.webp',
  ];

  int currentPage = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 3),
          (Timer timer) {
        if (_pageController.hasClients) {
          currentPage++;

          if (currentPage >= images.length) {
            currentPage = 0;
          }

          _pageController.animateToPage(
            currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  images[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Welcome to NepalHike',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}