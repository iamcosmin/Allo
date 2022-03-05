import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_image/firebase_image.dart';

enum _PersonPictureType { profilePicture, initials, determine }

// ignore: must_be_immutable
class PersonPicture extends HookWidget {
  final double radius;
  final _PersonPictureType _type;
  Color? color;
  Gradient? gradient;
  String? profilePicture;
  String? initials;
  String? stringKey;

  PersonPicture.profilePicture(
      {required this.radius, required this.profilePicture, Key? key})
      : _type = _PersonPictureType.profilePicture,
        super(key: key);

  PersonPicture.initials(
      {Key? key,
      required this.radius,
      required this.initials,
      this.color,
      this.gradient})
      : _type = _PersonPictureType.initials,
        super(key: key);

  PersonPicture.determine(
      {Key? key,
      required this.radius,
      required this.profilePicture,
      required this.initials,
      this.stringKey,
      this.color,
      @Deprecated('For performance reasons, please use color.') this.gradient})
      : _type = _PersonPictureType.determine,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_type == _PersonPictureType.profilePicture) {
      return ClipOval(
        child: SizedBox(
          height: radius,
          width: radius,
          child: Image.network(profilePicture!),
        ),
      );
    } else if (_type == _PersonPictureType.initials) {
      return ClipOval(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: radius,
          width: radius,
          decoration: BoxDecoration(
              color: (color == null && gradient == null)
                  ? Theme.of(context).colorScheme.primary
                  : color,
              gradient: gradient),
          child: Center(
            child: Text(
              initials!,
              style: TextStyle(
                fontSize: radius / 2,
                color: (color == null && gradient == null)
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            ),
          ),
        ),
      );
    } else if (_type == _PersonPictureType.determine) {
      return ClipOval(
        key: key,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          key: key,
          height: radius,
          width: radius,
          alignment: Alignment.center,
          child: Builder(
            key: key,
            builder: (context) {
              if (profilePicture != null && profilePicture!.isNotEmpty) {
                return Image(
                  key: key,
                  image: profilePicture!.startsWith('gs://')
                      ? FirebaseImage(profilePicture!)
                      : CachedNetworkImageProvider(profilePicture!)
                          as ImageProvider,
                  errorBuilder: (context, error, stackTrace) => Container(
                    key: key,
                    height: radius,
                    width: radius,
                    decoration: BoxDecoration(
                        color: (color == null && gradient == null)
                            ? Theme.of(context).colorScheme.primary
                            : color,
                        gradient: gradient),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        initials!,
                        style: TextStyle(
                          fontSize: radius / 2,
                          color: (color == null && gradient == null)
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  key: key,
                  height: radius,
                  width: radius,
                  decoration: BoxDecoration(
                      color: (color == null && gradient == null)
                          ? Theme.of(context).colorScheme.primary
                          : color,
                      gradient: gradient),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      initials!,
                      style: TextStyle(
                          fontSize: radius / 2,
                          color: (color == null && gradient == null)
                              ? Theme.of(context).colorScheme.onPrimary
                              : null),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } else {
      throw Exception(
          'Please use the underlying submethods for choosing how to display your person picture, as this class does not have a default.');
    }
  }
}
