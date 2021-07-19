import 'package:flutter/cupertino.dart';
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
      return Container(
        height: radius,
        width: radius,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100000000000),
          child: Image.network(profilePicture!),
        ),
      );
    } else if (_type == _PersonPictureType.initials) {
      return Container(
        height: radius,
        width: radius,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color, gradient: gradient),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            initials!,
            style: TextStyle(fontSize: radius / 2),
          ),
        ),
      );
    } else if (_type == _PersonPictureType.determine) {
      if (profilePicture != null) {
        return Container(
          height: radius,
          width: radius,
          child: ClipRRect(
            child: Image.network(profilePicture!),
            borderRadius: BorderRadius.circular(100000000000),
          ),
        );
      } else {
        return Container(
          height: radius,
          width: radius,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: color, gradient: gradient),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              initials!,
              style: TextStyle(fontSize: radius / 2),
            ),
          ),
        );
      }
    } else {
      throw Exception();
    }
  }
}
