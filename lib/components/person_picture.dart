import 'package:allo/components/photo.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: must_be_immutable
class PersonPicture extends HookConsumerWidget {
  final double radius;
  final String initials;
  final String? profilePicture;

  const PersonPicture(
      {required this.initials,
      required this.profilePicture,
      required this.radius,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipOval(
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          key: key,
          height: radius,
          width: radius,
          alignment: Alignment.center,
          child: Center(
            child: _child(context),
          )),
    );
  }

  Widget _child(BuildContext context) {
    if (profilePicture != null) {
      return Photo(
        key: key,
        url: profilePicture!,
        placeholder: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          color: Theme.of(context).colorScheme.primary,
          child: Text(
            initials,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: radius / 2,
            ),
          ),
        ),
      );
    } else {
      return Text(
        initials,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
  }
}
