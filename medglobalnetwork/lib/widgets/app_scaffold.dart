import 'package:flutter/material.dart';
import 'app_bottom_nav.dart';
import 'app_header.dart';
import 'app_sidebar.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.onNavTap,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      body: Column(
        children: [
          AppHeader(title: title),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: onNavTap,
      ),
    );
  }
}
