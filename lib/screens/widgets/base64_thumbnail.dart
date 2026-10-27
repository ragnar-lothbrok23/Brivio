import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Safely renders a Base64-encoded image thumbnail, falling back to a
/// broken-image icon instead of crashing the build if the string is
/// missing, malformed, or not decodable as an image.
class Base64Thumbnail extends StatelessWidget {
  const Base64Thumbnail({super.key, required this.base64String, double size = 40})
      : width = size,
        height = size;

  const Base64Thumbnail.rect({
    super.key,
    required this.base64String,
    required this.width,
    required this.height,
  });

  final String base64String;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    try {
      bytes = base64Decode(base64String);
    } catch (_) {
      bytes = null;
    }

    if (bytes == null || bytes.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.broken_image_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}
