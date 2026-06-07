import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import 'home/home_screen.dart';
import 'jobs/jobs_screen.dart';
import 'shop/shop_screen.dart';
import 'study/study_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Home', 'Study', 'Jobs', 'Shop'];

  final _screens = const [
    HomeScreen(),
    StudyScreen(),
    JobsScreen(),
    ShopScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _titles[_index],
      currentIndex: _index,
      onNavTap: (i) => setState(() => _index = i),
      body: _screens[_index],
    );
  }
}
