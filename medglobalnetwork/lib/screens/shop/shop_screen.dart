import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_rounded, size: 64, color: Color(0xFF0D6E6E)),
          SizedBox(height: 16),
          Text(
            'Shop',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Medical supplies marketplace coming soon',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
