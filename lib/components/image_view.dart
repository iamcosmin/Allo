import 'package:allo/components/photo.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ImageView extends HookConsumerWidget {
  final String imageUrl;
  final ColorScheme? colorScheme;
  const ImageView(this.imageUrl, {this.colorScheme, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = colorScheme ?? Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        leading: ClipOval(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: BackButton(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
      backgroundColor: colors.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Photo(
                backgroundColor: colors.surface,
                key: key,
                url: imageUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
