import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/gravatar.dart';
import '../../widgets/user_avatar.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _imageUrlController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _imageUrlController =
        TextEditingController(text: user?.profileImageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final previewUrl = _imageUrlController.text.isNotEmpty
        ? _imageUrlController.text
        : (_emailController.text.isNotEmpty
            ? gravatarUrl(_emailController.text)
            : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: UserAvatar(
                imageUrl: previewUrl,
                email: _emailController.text,
                radius: 50,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unique ID: ${user?.uniqueId ?? ''}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                helperText: 'Avatar is fetched from email via Gravatar',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Custom Profile Image URL',
                helperText: 'Override Gravatar with your own image URL',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        try {
                          await context.read<AuthProvider>().updateProfile(
                                displayName: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                profileImageUrl:
                                    _imageUrlController.text.trim().isEmpty
                                        ? null
                                        : _imageUrlController.text.trim(),
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _saving = false);
                        }
                      },
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
