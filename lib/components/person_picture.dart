import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum _PersonPictureType { profilePicture, initials }

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

  @override
  Widget build(BuildContext context) {
    if (_type == _PersonPictureType.profilePicture) {
      return Container(
        height: radius,
        width: radius,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipRRect(
          child: Image.network(profilePicture!),
          borderRadius: BorderRadius.circular(double.infinity),
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
    } else {
      throw Exception();
    }
  }
}
