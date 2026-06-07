import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/profile/profile_edit_screen.dart';
import 'user_avatar.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenu;

  const AppHeader({
    super.key,
    required this.title,
    this.showMenu = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (showMenu)
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                  ),
                  if (user != null)
                    Text(
                      'ID: ${user.uniqueId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                    ),
                ],
              ),
            ),
            UserAvatar(
              imageUrl: user?.profileImageUrl,
              email: user?.email,
              radius: 22,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileEditScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
