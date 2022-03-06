import 'dart:io';

import 'package:allo/components/builders.dart';
import 'package:allo/logic/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  const Photo(
      {required this.url, this.placeholder, this.backgroundColor, Key? key})
      : super(key: key);
  final String url;
  final Widget? placeholder;
  final Color? backgroundColor;

  Widget _errorBuilder(
      BuildContext context, Object error, StackTrace? stackTrace) {
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
                child: const Text('OK'))
          ],
        ),
      ),
      child: Center(
        child: Container(
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
    final color = backgroundColor ?? Theme.of(context).colorScheme.primary;
    if (isGS) {
      if (kIsWeb) {
        return FutureView<String>(
          key: key,
          future: FirebaseStorage.instance.refFromURL(url).getDownloadURL(),
          success: (context, data) {
            return Image.network(
              data,
              errorBuilder: _errorBuilder,
            );
          },
          loading: Container(
            color: color,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      } else if (Platform.isAndroid) {
        return Image(
          image: FirebaseImage(url),
          key: key,
          errorBuilder: _errorBuilder,
        );
      } else {
        throw Exception(
          'The platform that the app is being ran on is not currently supported by this widget. Please migrate the widget if, somehow, this app will be available on other platforms than Web and Android.',
        );
      }
    } else if (isHTTP) {
      if (kIsWeb) {
        return Image.network(
          url,
          key: key,
          errorBuilder: _errorBuilder,
        );
      } else if (Platform.isAndroid) {
        return CachedNetworkImage(
          imageUrl: url,
          key: key,
        );
      } else {
        throw Exception(
          'The platform that the app is being ran on is not currently supported by this widget. Please migrate the widget if, somehow, this app will be available on other platforms than Web and Android.',
        );
      }
    } else {
      throw Exception(
        'The provided url scheme is not supported. Please make sure that you are using gs:// or http(s):// as your url schemes.',
      );
    }
  }
}
