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

  PersonPicture.profilePicture({
    required this.radius,
    required this.profilePicture,
  }) : _type = _PersonPictureType.profilePicture;

  PersonPicture.initials(
      {required this.radius, required this.initials, this.color, this.gradient})
      : _type = _PersonPictureType.initials;

  PersonPicture.determine(
      {required this.radius,
      required this.profilePicture,
      required this.initials,
      this.color,
      this.gradient})
      : _type = _PersonPictureType.determine;

  @override
  Widget build(BuildContext context) {
    if (_type == _PersonPictureType.profilePicture) {
      return ClipOval(
        child: Container(
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
          child: Align(
            alignment: Alignment.center,
            child: Text(
              initials!,
              style: TextStyle(fontSize: radius / 2),
            ),
          ),
        ),
      );
    } else if (_type == _PersonPictureType.determine) {
      if (profilePicture != null) {
        return ClipOval(
          child: Container(
            height: radius,
            width: radius,
            child: Image.network(profilePicture!),
          ),
        );
      } else {
        return ClipOval(
          child: Container(
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
          ),
        );
      }
    } else {
      throw Exception();
    }
  }
}
