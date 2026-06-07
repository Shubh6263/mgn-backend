import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/gravatar.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? email;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.email,
    this.radius = 22,
    this.onTap,
  });

  String get _resolvedUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl!;
    if (email != null && email!.isNotEmpty) return gravatarUrl(email!);
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE2E8F0),
      child: _resolvedUrl.isEmpty
          ? Icon(Icons.person, size: radius, color: const Color(0xFF64748B))
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: _resolvedUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (_, __) => Icon(
                  Icons.person,
                  size: radius,
                  color: const Color(0xFF64748B),
                ),
                errorWidget: (_, __, ___) => Icon(
                  Icons.person,
                  size: radius,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
    );

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }
}
