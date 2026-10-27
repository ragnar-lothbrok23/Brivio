import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import 'base64_thumbnail.dart';

/// Small circular avatar for a dashboard's AppBar — the user's profile
/// photo if they've set one, otherwise a generic person icon.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.user, this.size = 28});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!user.hasPhoto) {
      return CircleAvatar(radius: size / 2, child: const Icon(Icons.person));
    }
    return ClipOval(child: Base64Thumbnail(base64String: user.photoBase64!, size: size));
  }
}
