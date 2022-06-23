import 'dart:developer';
import 'dart:io';

import 'package:allo/logic/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Photo extends HookConsumerWidget {
  /// [Photo] is a widget that makes the use of 'gs://' easier.
  /// It also makes all Images compatible with web and benefit of caching
  /// strategies.
  ///
  ///
  /// The accepted url schemes are http://, https:// and gs://.
  /// For each of the url schemes, the [Photo] widget will have different
  /// builders.
  ///
  ///
  /// For web, the app uses [Image.network] as it caches the image too.
  ///
  /// For android, the app uses a combination of [FirebaseImage] if the
  /// url scheme is gs://, and [CachedNetworkImage] if the url scheme
  /// is http:// or https://
  ///
  /// This widget is the most useful if you have 'gs://' links in you app,
  /// but you do not want to fill your app with [FutureBuilder] to await
  /// the download URL of the Firebase Storage bucket.
  const Photo({
    required this.url,
    this.placeholder,
    this.backgroundColor,
    this.errorBuilder = _errorBuilder,
    super.key,
  });
  final String url;
  final Widget? placeholder;
  final Color? backgroundColor;
  final Widget Function(BuildContext, Object, StackTrace?) errorBuilder;

  static Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    log(stackTrace: stackTrace, error: error, 'Error with Photo');
    return InkWell(
      onLongPress: () => Core.stub.alert(
        context: context,
        dialogBuilder: DialogBuilder(
          icon: Icons.error,
          title: context.locale.error,
          body: SelectableText(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      ),
      child: Center(
        child: ColoredBox(
          color: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGS = url.startsWith('gs://');
    final isHTTP = url.startsWith('http://') || url.startsWith('https://');
    if (isGS) {
      return Image(
        image: FirebaseImage(url),
        key: key,
        errorBuilder: _errorBuilder,
      );
    } else if (isHTTP) {
      if (kIsWeb) {
        return Image.network(
          url,
          key: key,
          errorBuilder: _errorBuilder,
        );
      } else if (Platform.isAndroid) {
        return Image(
          image: CachedNetworkImageProvider(
            url,
            cacheKey: key.toString(),
          ),
          errorBuilder: _errorBuilder,
        );
      } else {
        throw Exception(
          'The platform that the app is being ran on is not currently supported by this widget. Please migrate the widget if, somehow, this app will be available on other platforms than Web and Android.',
        );
      }
    } else {
      throw Exception(
        'The provided url scheme is not supported. Your scheme is ${url.split('//')[0]}. Make sure that you are using gs:// or http(s):// as your url schemes.',
      );
    }
  }
}
