import 'package:allo/components/photo.dart';
import 'package:allo/components/pinch_to_zoom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ImageView extends HookConsumerWidget {
  final String imageUrl;
  final ColorScheme? colorScheme;
  const ImageView(this.imageUrl, {this.colorScheme, Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = colorScheme ?? Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),
      backgroundColor: colors.surface,
      body: Center(
        child: PinchZoom(
          child: Photo(
            backgroundColor: colors.surface,
            key: key,
            url: imageUrl,
          ),
        ),
      ),
    );
  }
}
