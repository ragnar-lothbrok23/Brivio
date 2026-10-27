import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Full-screen, pinch-to-zoom view of a single image, opened from any of
/// the small thumbnails around the app (invoice photos, progress photos,
/// profile photo).
class FullscreenImageViewer extends StatelessWidget {
  const FullscreenImageViewer({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: Image.memory(bytes),
        ),
      ),
    );
  }
}

/// Decodes [base64String] and pushes it as a full-screen viewer; does
/// nothing if the string isn't valid image data, so callers don't need to
/// re-check what [Base64Thumbnail] already safely handled for display.
void showFullscreenImage(BuildContext context, String base64String) {
  Uint8List bytes;
  try {
    bytes = base64Decode(base64String);
  } catch (_) {
    return;
  }
  if (bytes.isEmpty) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => FullscreenImageViewer(bytes: bytes),
      fullscreenDialog: true,
    ),
  );
}
