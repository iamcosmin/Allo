import 'package:allo/components/progress_rings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum _PersonPictureType { profilePicture, initials, determine }

// ignore: must_be_immutable
class PersonPicture extends HookWidget {
  final double radius;
  final _PersonPictureType _type;
  Color? color;
  Gradient? gradient;
  String? profilePicture;
  String? initials;

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
      this.color,
      this.gradient})
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
        child: Container(
          height: radius,
          width: radius,
          decoration: BoxDecoration(color: color, gradient: gradient),
          child: Center(
            child: Text(
              initials!,
              style: TextStyle(
                fontSize: radius / 2,
              ),
            ),
          ),
        ),
      );
    } else if (_type == _PersonPictureType.determine) {
      return ClipOval(
        child: SizedBox(
          height: radius,
          width: radius,
          child: Builder(
            builder: (context) {
              if (profilePicture == null) {
                return Container(
                  height: radius,
                  width: radius,
                  decoration: BoxDecoration(color: color, gradient: gradient),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      initials!,
                      style: TextStyle(fontSize: radius / 2),
                    ),
                  ),
                );
              } else {
                return CachedNetworkImage(
                  imageUrl: profilePicture!,
                  progressIndicatorBuilder: (context, string, progress) =>
                      const ProgressRing(),
                  errorWidget: (context, str, dn) {
                    return Container(
                      height: radius,
                      width: radius,
                      decoration:
                          BoxDecoration(color: color, gradient: gradient),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          initials!,
                          style: TextStyle(fontSize: radius / 2),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      );
    } else {
      throw Exception();
    }
  }
}
