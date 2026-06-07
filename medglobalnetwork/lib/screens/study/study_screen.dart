import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 64, color: Color(0xFF0D6E6E)),
          SizedBox(height: 16),
          Text(
            'Study',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Medical courses & resources coming soon',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
