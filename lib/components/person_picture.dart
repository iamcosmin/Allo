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
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(1000)),
        child: Image.network(profilePicture!),
      );
    } else if (_type == _PersonPictureType.initials) {
      return Container(
        alignment: Alignment.center,
        height: radius,
        width: radius,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            color: color,
            gradient: gradient),
        child: Text(
          initials!,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: radius / 2),
        ),
      );
    } else {
      throw Exception();
    }
  }
}
