import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'user_avatar.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            UserAvatar(
              imageUrl: user?.profileImageUrl,
              email: user?.email,
              radius: 40,
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'MedGlobal User',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (user?.email != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  user!.email!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'UID: ${user?.uniqueId ?? '---'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D6E6E),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            _SidebarItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _SidebarItem(
              icon: Icons.menu_book_rounded,
              label: 'Study',
              onTap: () => Navigator.pop(context),
            ),
            _SidebarItem(
              icon: Icons.work_rounded,
              label: 'Jobs',
              onTap: () => Navigator.pop(context),
            ),
            _SidebarItem(
              icon: Icons.storefront_rounded,
              label: 'Shop',
              onTap: () => Navigator.pop(context),
            ),
            _SidebarItem(
              icon: Icons.fingerprint_rounded,
              label: 'Fingerprint Login',
              onTap: () async {
                await auth.enableBiometric();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fingerprint login enabled')),
                  );
                }
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
              title: const Text('Logout', style: TextStyle(color: Color(0xFFDC2626))),
              onTap: () async {
                await auth.signOut();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D6E6E)),
      title: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
